0a. Study @GOAL.md to understand the creative brief.
0b. Study @CLAUDE.md to understand the project concept, aesthetic direction, and architecture.
0c. Study @AGENTS.md for how to build, run, and test the project.
0d. Study @IMPLEMENTATION_PLAN.md and choose the most important item to address.
0e. For reference, the application source code is in `src/*`.

1. Your task is to implement functionality per the plan using parallel subagents. Follow @IMPLEMENTATION_PLAN.md and choose the most important item. Before making changes, search the codebase (don't assume not implemented) using Sonnet subagents. You may use up to 100 parallel Sonnet subagents for searches/reads and only 1 subagent for build/tests. Use Opus subagents when complex reasoning is needed (debugging, architectural decisions, design direction).

2. After implementing functionality or resolving problems, run the build and any tests for that unit of work. If functionality is missing then it's your job to add it as per the concept in @CLAUDE.md. Ultrathink.

3. When you discover issues, immediately update @IMPLEMENTATION_PLAN.md with your findings using a subagent. When resolved, update and remove the item.

4. When the build passes, update @IMPLEMENTATION_PLAN.md, then `git add -A` then `git commit` with a descriptive message. After the commit, `git push origin main`.

5. When working on frontend/UI: Load the frontend-design skill. Make BOLD aesthetic choices — distinctive typography, purposeful color palettes, meaningful motion, asymmetric layouts. Avoid Inter, Roboto, purple gradients, generic card grids. The UI should have a point of view. Every visual decision should be intentional. Use the UX design skills if available for interaction patterns and usability.

6. After each commit, verify the app runs locally (check @AGENTS.md for commands). If the deploy would be broken, fix it before moving to the next task. A broken deploy blocks everything.

99999. Important: When authoring any documentation or comments, capture the WHY — design intent, architectural reasoning, what makes this interesting.

999999. Important: Single sources of truth. If tests unrelated to your work fail, resolve them as part of the increment.

9999999. As soon as there are no build errors, create a git tag. If there are no git tags start at 0.0.1 and increment patch by 1.

99999999. You may add extra logging if required to debug issues.

999999999. Keep @IMPLEMENTATION_PLAN.md current with learnings using a subagent — future work depends on this to avoid duplicating efforts. Update especially after finishing your turn.

9999999999. When you learn something new about how to build or run the project, update @AGENTS.md using a subagent but keep it brief and operational. Do NOT put status updates or progress notes in AGENTS.md — those belong in IMPLEMENTATION_PLAN.md.

99999999999. For any bugs you notice, resolve them or document them in @IMPLEMENTATION_PLAN.md using a subagent even if unrelated to current work.

999999999999. Implement functionality COMPLETELY. Placeholders, stubs, and TODO comments waste loops redoing the same work. Full implementations only.

9999999999999. IMPORTANT: Every few commits, step back and look at the app holistically. Does it feel cohesive? Does the aesthetic hold together? Is there a detail that would elevate the whole experience? Add polish tasks to @IMPLEMENTATION_PLAN.md. Craft matters.

99999999999999. If you find yourself stuck on something for more than a few attempts, document the blocker in @IMPLEMENTATION_PLAN.md and move to the next most important task. Come back to it with fresh context in a future loop.
