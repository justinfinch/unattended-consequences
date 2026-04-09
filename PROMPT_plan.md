0a. Study @GOAL.md to understand the mission, engineering philosophy, and constraints.
0b. Study @specs/* to understand any concept, architecture, or aesthetic direction established so far.
0c. Study @AGENTS.md to understand how to build/run the project (if it exists yet).
0d. Study @IMPLEMENTATION_PLAN.md (if present; it may be incorrect or outdated).
0e. For reference, the application source code is in src/* (if it exists yet).

== PHASE 1: RESEARCH ==

1. If no concept has been chosen yet (no specs/concept.md exists):

   a. Use web search to research common small business pain points. Look at:
      - What small business owners complain about on forums, Reddit, HN
      - What categories of SaaS tools have high churn or poor satisfaction
      - Where small businesses still use spreadsheets, paper, or manual processes
      - Problems that existing solutions over-engineer or overcharge for

   b. Use an Opus subagent to evaluate 5+ candidate problems against:
      - Solvability: Can this be meaningfully solved with a self-contained web app?
      - Scope: Can a working MVP be built in ~50-100 loop iterations?
      - Domain richness: Is there a real domain to model (not just CRUD)?
      - Technical fit: Can it run on Railway with open-source infrastructure?
      - DTU feasibility: Are the external services needed (if any) clonable?
      Ultrathink. Pick the problem with the best combination of these factors.

   c. Write specs/concept.md:
      - The problem: what pain point, who experiences it, why it matters
      - The solution: what the app does, core workflows, key differentiators
      - Why this problem: rationale for choosing it over alternatives
      - Success criteria: how to know if the app actually solves the problem

== PHASE 2: DOMAIN MODEL & ARCHITECTURE ==

2. Use an Opus subagent to design the domain model. Ultrathink. Write specs/architecture.md:
   - Bounded contexts: what are the subdomains and their boundaries?
   - Aggregates and entities: what are the core domain objects?
   - Value objects: what are the immutable domain concepts?
   - Domain events: what state changes drive workflows?
   - Anti-corruption layers: what external services are needed, and what
     translation layers sit between them and the domain?
   - DTU twins: which services need behavioral clones for development?
   - Tech stack: language, framework, database, deployment topology
   - Project structure: how directories map to bounded contexts

3. Write specs/aesthetic.md:
   - Design language and UI philosophy appropriate to the target user
   - Typography, color palette, spacing system
   - Component patterns (forms, tables, navigation, dashboards)
   - The app should look professional and trustworthy — small business
     owners judge software by how it looks

== PHASE 3: PLAN ==

4. Create @IMPLEMENTATION_PLAN.md:
   - Begin with a 2-3 sentence summary of the concept
   - Phase 1 — Deployable skeleton: Dockerfile/Nixpacks, PORT config,
     health check, landing page, basic project structure with DDD layers
     (domain, application, infrastructure, presentation)
   - Phase 2 — Core domain: aggregates, repositories, application services,
     core workflows end-to-end
   - Phase 3 — DTU twins and external service integration
   - Phase 4 — Polish, product quality, first-run experience

5. Create @HUMAN_TASKS.md:
   - Any accounts to create, API keys to obtain, DNS to configure
   - OAuth app registration steps (if social auth is planned)
   - Railway environment variable setup
   - Each task should have clear step-by-step instructions

== RULES ==

IMPORTANT: Plan only. Do NOT implement anything.

IMPORTANT: The domain model in specs/architecture.md is the most critical
output of this phase. Spend the most time here. Bad domain modeling creates
problems that compound every iteration.

IMPORTANT: Use up to 100 Sonnet subagents for parallel research and reads.
Use Opus subagents only for complex reasoning (domain modeling, evaluating
trade-offs, architectural decisions).

999. When @IMPLEMENTATION_PLAN.md becomes large, periodically clean out
completed items using a subagent.

9999. If the concept isn't working or the domain model feels forced,
document why in specs/concept.md and pivot. Better to change direction
early than grind on a weak domain.
