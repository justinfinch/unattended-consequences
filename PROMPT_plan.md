0a. Study @GOAL.md to understand the creative brief and constraints.
0b. Study @CLAUDE.md to understand any project context established so far.
0c. Study @AGENTS.md to understand how to build/run the project (if it exists yet).
0d. Study @IMPLEMENTATION_PLAN.md (if present) to understand the plan so far. It may be incorrect.
0e. For reference, the application source code is in `src/*` (if it exists yet).

1. If no concept has been chosen yet: Use an Opus subagent to brainstorm 5 genuinely novel concepts that fit the creative brief. Pick the most surprising and ambitious one. Document your chosen concept, its aesthetic direction, and its technical architecture in @CLAUDE.md. Ultrathink. The concept should be something a stranger would bookmark — not generic, not expected, not boring.

2. If a concept exists: Use up to 100 Sonnet subagents to study existing source code in `src/*` and compare it against the concept described in @CLAUDE.md. Use an Opus subagent to analyze findings, prioritize tasks, and create/update @IMPLEMENTATION_PLAN.md as a bullet point list sorted in priority of items yet to be implemented. Ultrathink. Consider searching for TODO, minimal implementations, placeholders, skipped tests, and broken functionality. Study @IMPLEMENTATION_PLAN.md to determine starting point for research and keep it up to date with items considered complete/incomplete using subagents.

3. When planning frontend work: Load the frontend-design skill and any UX design skills available. The plan should include explicit tasks for visual polish, typography choices, animation/motion design, responsive layout, and accessibility. These are not afterthoughts — they are first-class implementation tasks. Plan for the app to feel crafted, not generated.

4. Plan for Railway deployment early. Include tasks for: Dockerfile or Nixpacks setup, PORT env var configuration, health check endpoint, and a meaningful landing experience from the very first deploy.

IMPORTANT: Plan only. Do NOT implement anything. Do NOT assume functionality is missing; confirm with code search first.

IMPORTANT: Begin @IMPLEMENTATION_PLAN.md with a 2-3 sentence summary of the concept and why it's interesting, then list prioritized tasks. Group tasks into phases: Phase 1 (deployable skeleton), Phase 2 (core functionality), Phase 3 (polish + delight).

999. When @IMPLEMENTATION_PLAN.md becomes large, periodically clean out completed items using a subagent.

9999. If you find the concept isn't working or is less interesting than expected, document why in @CLAUDE.md and pivot. Better to change direction early than grind on something mediocre.
