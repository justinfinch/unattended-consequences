0a. Study @specs/* to understand the concept, architecture, and aesthetic direction.
0b. Study @AGENTS.md for how to build, run, and test the project.
0c. Study @IMPLEMENTATION_PLAN.md and choose the most important item to address.
0d. For reference, the application source code is in src/*.

1. Implement the chosen item using parallel Sonnet subagents. Before making changes, search the codebase (don't assume not implemented) using Sonnet subagents. You may use up to 100 parallel Sonnet subagents for searches/reads and only 1 Sonnet subagent for build/tests. Use Opus subagents only for complex reasoning (debugging, architectural decisions). When implementing a significant feature (not a small fix), follow this workflow: first use a code-explorer agent to understand relevant existing code and patterns, then use a code-architect agent to design the approach, implement it, then use a code-reviewer agent to catch bugs and convention violations before committing. Skip the exploration/architecture phases for small fixes or polish tasks.

2. After implementing, run the build and tests for that unit of work using a single subagent. If functionality is missing then it's your job to add it as per specs/*. Ultrathink.

3. When you discover issues, immediately update @IMPLEMENTATION_PLAN.md with your findings using a Sonnet subagent. When resolved, update and remove the item.

4. ONLY when the build passes AND tests pass: update @IMPLEMENTATION_PLAN.md using a Sonnet subagent, then `git add -A` then `git commit` with a descriptive message, then `git push origin main`. Do NOT commit if the build is broken.

5. When working on frontend/UI: Load the frontend-design skill and follow the aesthetic direction in @specs/aesthetic.md.

6. After each commit, verify the app starts and responds on $PORT (check @AGENTS.md for commands). If broken, fix before moving to the next task.

99999. When authoring documentation or comments, capture the WHY — design intent, architectural reasoning.

999999. Single sources of truth. If tests unrelated to your work fail, resolve them as part of the increment.

9999999. As soon as there are no build or test errors, create a git tag. Increment patch from the latest existing tag (start at 0.0.1).

99999999. You may add extra logging if required to debug issues.

999999999. Keep @IMPLEMENTATION_PLAN.md current with learnings using a Sonnet subagent. Update especially after finishing your turn.

9999999999. When you learn something new about how to build or run the project, update @AGENTS.md using a Sonnet subagent but keep it brief and operational. No status updates or progress notes in AGENTS.md.

99999999999. For any bugs you notice, resolve them or document them in @IMPLEMENTATION_PLAN.md using a Sonnet subagent even if unrelated to current work.

999999999999. Implement functionality COMPLETELY. Placeholders, stubs, and TODO comments waste loops. Full implementations only. DO IT OR I WILL YELL AT YOU.

9999999999999. Every few commits, step back holistically. Does the app feel cohesive? Add polish tasks to @IMPLEMENTATION_PLAN.md. Craft matters.

99999999999999. If stuck for more than a few attempts, document the blocker in @IMPLEMENTATION_PLAN.md and move to the next task. Fresh context in a future loop will handle it.
