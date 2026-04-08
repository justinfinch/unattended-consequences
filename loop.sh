#!/bin/bash
set -euo pipefail

# =============================================================================
# Ralph Wiggum Loop — Weekend Creative Experiment
# =============================================================================
# Usage:
#   ./loop.sh              # Build mode, unlimited iterations
#   ./loop.sh 20           # Build mode, max 20 iterations
#   ./loop.sh plan         # Plan mode, unlimited iterations
#   ./loop.sh plan 5       # Plan mode, max 5 iterations
# =============================================================================

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
echo "  🧠 Ralph Wiggum Loop — Weekend Experiment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Mode:   $MODE"
echo "  Prompt: $PROMPT_FILE"
echo "  Branch: $CURRENT_BRANCH"
echo "  Log:    $LOG_FILE"
[ $MAX_ITERATIONS -gt 0 ] && echo "  Max:    $MAX_ITERATIONS iterations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: $PROMPT_FILE not found"
    exit 1
fi

while true; do
    if [ $MAX_ITERATIONS -gt 0 ] && [ $ITERATION -ge $MAX_ITERATIONS ]; then
        echo ""
        echo "━━━ Reached max iterations: $MAX_ITERATIONS ━━━"
        break
    fi

    ITERATION=$((ITERATION + 1))
    echo ""
    echo "======================== LOOP $ITERATION $(date) ========================" | tee -a "$LOG_FILE"
    echo ""

    # Run Ralph iteration
    # -p: Headless mode (non-interactive, reads from stdin)
    # --dangerously-skip-permissions: Auto-approve all tool calls
    # --model: Opus for complex reasoning (task selection, prioritization)
    # --verbose: Detailed execution logging
    cat "$PROMPT_FILE" | claude -p \
        --dangerously-skip-permissions \
        --output-format=stream-json \
        --model opus \
        --verbose \
        2>&1 | tee -a "$LOG_FILE"

    # Push changes after each iteration
    echo "" | tee -a "$LOG_FILE"
    echo "--- Pushing to $CURRENT_BRANCH ---" | tee -a "$LOG_FILE"
    git push origin "$CURRENT_BRANCH" 2>&1 | tee -a "$LOG_FILE" || {
        echo "Creating remote branch..." | tee -a "$LOG_FILE"
        git push -u origin "$CURRENT_BRANCH" 2>&1 | tee -a "$LOG_FILE"
    }

    # Brief pause between iterations
    sleep 5
done

echo ""
echo "━━━ Ralph loop complete. Check $LOG_FILE for full output. ━━━"
