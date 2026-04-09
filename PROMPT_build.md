0a. Study @specs/* to understand the concept, domain model, architecture, and aesthetic direction.
0b. Study @AGENTS.md for how to build, run, and test the project.
0c. Study @IMPLEMENTATION_PLAN.md and choose the highest-priority incomplete item.
0d. Study @LOOP_LOG.md (if present) to understand what previous iterations accomplished and any concerns raised.
0e. For reference, the application source code is in src/*.

== IMPLEMENT ==

1. Implement the chosen item. Before making changes, search the codebase first — don't assume something isn't implemented.

   For SIGNIFICANT features (new aggregates, new bounded contexts, new workflows):
   - Use a code-explorer agent to understand relevant existing code and patterns
   - Use a code-architect agent to design the approach at the domain level
   - Implement following DDD layering:
     * Domain layer: aggregates, entities, value objects, domain events, repository interfaces (NO framework dependencies)
     * Application layer: application services, command/query handlers, DTOs
     * Infrastructure layer: repository implementations, adapters, DTU twins, anti-corruption layers
     * Presentation layer: routes, controllers, views, API endpoints
   - Use a code-reviewer agent to catch bugs and convention violations before committing
   - Write tests: domain logic gets unit tests, workflows get integration tests

   For SMALL fixes or polish tasks:
   - Just do it. Skip the exploration/architecture phases.
   - Still write tests for non-trivial logic.

2. Use up to 100 parallel Sonnet subagents for searches and reads. Use only 1 Sonnet subagent for builds and tests. Use Opus subagents only for complex reasoning (debugging, domain modeling decisions, architectural trade-offs).

== VERIFY ==

3. After implementing, verify before committing:
   - Build passes (check @AGENTS.md for commands)
   - Tests pass
   - App starts and responds on $PORT
   - No lint or type errors
   - The domain model is consistent — new code follows ubiquitous language,
     aggregates enforce their invariants, events are explicit

4. ONLY when verification passes: update @IMPLEMENTATION_PLAN.md, then
   git add relevant files, git commit with a descriptive message, git push origin main.
   Do NOT commit if the build is broken.

== FEEDBACK LOOP ==

5. After committing, write a self-assessment to @LOOP_LOG.md (append, don't overwrite):

   ```
   ## Iteration [N] — [date]
   **Task**: What was implemented
   **Result**: Did it work? Any issues?
   **Domain health**: Is the model clean? Any aggregate boundaries feeling wrong?
   **Product health**: Does the app feel cohesive? Any UX concerns?
   **Next priority**: What should the next iteration focus on?
   **Concerns**: Anything that feels off or risky
   ```

6. Update @HUMAN_TASKS.md if you discovered new things requiring human action.

7. After each commit, verify the app starts and responds on $PORT.
   If broken, fix before moving to the next task.

== DDD GUARDRAILS ==

- Domain objects NEVER import from infrastructure or presentation layers
- Aggregates are the consistency boundary — don't reach across aggregates in a transaction
- Use domain events to coordinate between bounded contexts, not direct calls
- Repository interfaces live in the domain layer; implementations in infrastructure
- DTU twins implement the same adapter interface as the real service — swapping is a config change
- If you're writing a "service" class with no domain logic, it's probably anemic. Put the behavior on the aggregate.
- Ubiquitous language is non-negotiable. If the domain calls it a "booking," the code calls it a Booking.

== OPERATIONAL ==

99999. Capture the WHY in documentation and comments — design intent, architectural reasoning.

999999. Single sources of truth. If tests unrelated to your work fail, resolve them.

9999999. As soon as there are no build or test errors, create a git tag. Increment patch from the latest existing tag (start at 0.0.1).

99999999. Keep @IMPLEMENTATION_PLAN.md current with learnings. Update especially after finishing your turn.

999999999. When you learn something new about how to build or run the project, update @AGENTS.md but keep it brief and operational.

9999999999. For any bugs you notice, resolve them or document them in @IMPLEMENTATION_PLAN.md even if unrelated to current work.

99999999999. Implement functionality COMPLETELY. Placeholders, stubs, and TODO comments waste loops. Full implementations only.

999999999999. Every few commits, step back holistically. Does the app feel cohesive? Is the domain model holding up? Add polish tasks to @IMPLEMENTATION_PLAN.md.

9999999999999. If stuck for more than a few attempts, document the blocker in @IMPLEMENTATION_PLAN.md and move to the next task.
