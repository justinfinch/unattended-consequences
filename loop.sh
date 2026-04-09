#!/bin/bash

# =============================================================================
# Ralph Wiggum Loop — ralph-goes-wild
# =============================================================================
# Usage:
#   ./loop.sh              # Build mode, unlimited iterations
#   ./loop.sh 20           # Build mode, max 20 iterations
#   ./loop.sh plan         # Plan mode, unlimited
#   ./loop.sh plan 5       # Plan mode, max 5 iterations
# =============================================================================

# NOTE: No `set -e` — the loop must survive individual iteration failures.

# Rate limit wait time (seconds). Claude Max hits limits ~every 5 hours.
RATE_LIMIT_WAIT=1800  # 30 minutes

# Parse arguments
if [ "${1:-}" = "plan" ]; then
    MODE="plan"
    PROMPT_FILE="PROMPT_plan.md"
    MAX_ITERATIONS=${2:-0}
elif [[ "${1:-}" =~ ^[0-9]+$ ]]; then
    MODE="build"
    PROMPT_FILE="PROMPT_build.md"
    MAX_ITERATIONS=$1
else
    MODE="build"
    PROMPT_FILE="PROMPT_build.md"
    MAX_ITERATIONS=0
fi

ITERATION=0
CURRENT_BRANCH=$(git branch --show-current)
LOG_FILE="ralph-$(date +%Y%m%d-%H%M%S).log"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🧠 ralph-goes-wild"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Mode:   $MODE"
echo "  Prompt: $PROMPT_FILE"
echo "  Branch: $CURRENT_BRANCH"
echo "  Log:    $LOG_FILE"
[ "$MAX_ITERATIONS" -gt 0 ] 2>/dev/null && echo "  Max:    $MAX_ITERATIONS iterations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: $PROMPT_FILE not found"
    exit 1
fi

# Capture HEAD before each iteration for auto-revert
get_head() {
    git rev-parse HEAD 2>/dev/null
}

while true; do
    if [ "$MAX_ITERATIONS" -gt 0 ] 2>/dev/null && [ "$ITERATION" -ge "$MAX_ITERATIONS" ] 2>/dev/null; then
        echo ""
        echo "━━━ Reached max iterations: $MAX_ITERATIONS ━━━"
        break
    fi

    ITERATION=$((ITERATION + 1))
    HEAD_BEFORE=$(get_head)

    echo "" | tee -a "$LOG_FILE"
    echo "======================== LOOP $ITERATION $(date) ========================" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"

    # Run Ralph iteration
    ITER_OUTPUT=$(cat "$PROMPT_FILE" | claude -p \
        --dangerously-skip-permissions \
        --output-format=stream-json \
        --model opus \
        --verbose \
        2>&1 | tee -a "$LOG_FILE")

    # Check for rate limit / API limit errors
    if echo "$ITER_OUTPUT" | grep -qi "rate.limit\|too many requests\|quota\|billing\|overloaded\|capacity\|529\|429"; then
        echo "" | tee -a "$LOG_FILE"
        echo "━━━ Rate limit detected. Waiting ${RATE_LIMIT_WAIT}s ($(($RATE_LIMIT_WAIT / 60))m) ━━━" | tee -a "$LOG_FILE"
        sleep "$RATE_LIMIT_WAIT"
        ITERATION=$((ITERATION - 1))  # Don't count this as an iteration
        continue
    fi

    # Post-iteration: check if build is broken (build mode only)
    if [ "$MODE" = "build" ]; then
        HEAD_AFTER=$(get_head)

        # Only check if commits were made
        if [ "$HEAD_BEFORE" != "$HEAD_AFTER" ]; then
            # Try to detect build command from AGENTS.md
            BUILD_CMD=""
            if [ -f "AGENTS.md" ]; then
                # Look for npm/node build commands
                BUILD_CMD=$(grep -oP '(npm run build|npm start|node [^ ]+)' AGENTS.md | head -1)
            fi

            # Fallback: try common build commands
            if [ -z "$BUILD_CMD" ] && [ -f "package.json" ]; then
                if grep -q '"build"' package.json 2>/dev/null; then
                    BUILD_CMD="npm run build"
                fi
            fi

            # If we found a build command, verify it passes
            if [ -n "$BUILD_CMD" ]; then
                echo "--- Verifying build: $BUILD_CMD ---" | tee -a "$LOG_FILE"
                if ! eval "$BUILD_CMD" >> "$LOG_FILE" 2>&1; then
                    echo "━━━ BUILD BROKEN — reverting to $HEAD_BEFORE ━━━" | tee -a "$LOG_FILE"
                    git reset --hard "$HEAD_BEFORE"
                    echo "Reverted. Next loop will try a different approach." | tee -a "$LOG_FILE"
                fi
            fi
        fi
    fi

    # Push changes
    echo "" | tee -a "$LOG_FILE"
    echo "--- Pushing to $CURRENT_BRANCH ---" | tee -a "$LOG_FILE"
    git push origin "$CURRENT_BRANCH" >> "$LOG_FILE" 2>&1 || {
        echo "Creating remote branch..." | tee -a "$LOG_FILE"
        git push -u origin "$CURRENT_BRANCH" >> "$LOG_FILE" 2>&1 || true
    }

    # Brief pause between iterations
    sleep 5
done

echo ""
echo "━━━ Ralph loop complete. $ITERATION iterations. Check $LOG_FILE ━━━"
