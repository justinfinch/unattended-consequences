0a. Study @GOAL.md to understand the creative brief and constraints.
0b. Study @specs/* to understand any concept, architecture, or aesthetic direction established so far.
0c. Study @AGENTS.md to understand how to build/run the project (if it exists yet).
0d. Study @IMPLEMENTATION_PLAN.md (if present; it may be incorrect).
0e. For reference, the application source code is in src/* (if it exists yet).

1. If no concept has been chosen yet (no specs/concept.md exists): Use an Opus subagent to brainstorm 5 genuinely novel concepts that fit the creative brief. Ultrathink. Pick the most surprising and ambitious one. Then use Sonnet subagents to write:
   - specs/concept.md — what we're building and why it's interesting
   - specs/architecture.md — tech stack, project structure, deployment approach
   - specs/aesthetic.md — typography, color, motion, spatial composition, overall vibe
   The concept should be something a stranger would bookmark.

2. If a concept exists: Use up to 100 Sonnet subagents to study existing source code in src/* and compare it against specs/*. Use an Opus subagent to analyze findings. Use a code-explorer agent to trace execution paths and map architecture layers when studying existing source code, prioritize tasks, and create/update @IMPLEMENTATION_PLAN.md as a bullet point list sorted in priority of items yet to be implemented. Ultrathink. Consider searching for TODO, minimal implementations, placeholders, skipped tests, and broken functionality. Keep @IMPLEMENTATION_PLAN.md up to date with items considered complete/incomplete using subagents. Do NOT assume functionality is missing; confirm with code search first.

3. Plan for Railway deployment early. Phase 1 tasks should include: Dockerfile or Nixpacks setup, PORT env var configuration, health check endpoint, and a meaningful landing experience from the very first deploy.

IMPORTANT: Plan only. Do NOT implement anything.

IMPORTANT: Begin @IMPLEMENTATION_PLAN.md with a 2-3 sentence summary of the concept, then list prioritized tasks grouped into phases: Phase 1 (deployable skeleton), Phase 2 (core functionality), Phase 3 (polish + delight).

999. When @IMPLEMENTATION_PLAN.md becomes large, periodically clean out completed items using a subagent.

9999. If the concept isn't working or is less interesting than expected, document why in specs/concept.md and pivot. Better to change direction early than grind on something mediocre.
