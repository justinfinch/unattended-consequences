# Unattended Consequences

Autonomous coding experiment. Claude Code runs in a loop — researching a
real small business pain point, designing a DDD-based solution, and building
it on Railway. No human in the loop during execution.

## How It Works

1. `./loop.sh plan` — Claude researches small business pain points, picks one,
   designs a domain model, writes specs, and creates an implementation plan
2. `./loop.sh` — Claude picks the next task, implements it (with DDD layering,
   tests, and self-review), commits, and pushes. Railway auto-deploys.
3. Repeat until you check the URL.

## Key Files

| File | Purpose |
|------|---------|
| `GOAL.md` | Mission brief and engineering philosophy |
| `specs/` | Concept, architecture (domain model), aesthetic direction |
| `IMPLEMENTATION_PLAN.md` | Prioritized task list (Claude generates/updates) |
| `HUMAN_TASKS.md` | Things only a human can do (account setup, API keys) |
| `LOOP_LOG.md` | Claude's running self-assessment across iterations |
| `AGENTS.md` | How to build, run, test |
| `PROMPT_plan.md` | Planning mode prompt |
| `PROMPT_build.md` | Build mode prompt |

## Engineering Approach

- **Domain-Driven Design** (Evans/Vernon) — ubiquitous language, rich domain
  models, bounded contexts, domain events, anti-corruption layers
- **DTU Twins** — behavioral clones of third-party services for autonomous
  development. Human connects real services later via `HUMAN_TASKS.md`.
- **Open-source infrastructure** — self-hosted wherever possible, containerized

## Branching Model

`main` is the reusable template — loop scripts, prompts, and project scaffolding.
Each product lives on its own branch that diverges permanently from main.

```
main (template)
├── product-invoicely    (diverges, never merges back)
├── product-bookkeeper   (diverges, never merges back)
└── product-schedulr     (diverges, never merges back)
```

### Spawning a new product

```bash
git checkout -b product-<name> main
# Create a Railway service pointing at this branch
./loop.sh plan        # Claude researches and picks a problem
./loop.sh             # Claude builds it
```

Each product branch gets its own Railway service configured to deploy from
that branch. The loop pushes to whatever branch it's on — no merge to main.

Feature branches off a product branch are fine if the loop wants them.

## Quick Start

```bash
# 1. Set up environment (devcontainer handles this)
# 2. Create a product branch
git checkout -b product-<name> main
# 3. Plan
./loop.sh plan
# 4. Build
./loop.sh
# 5. Monitor
tail -f ralph-*.log
```

## Monitoring

- Watch `ralph-*.log` for real-time output
- Check Railway dashboard for deploy status
- Read `LOOP_LOG.md` for Claude's self-assessment
- Read `IMPLEMENTATION_PLAN.md` to see what's planned/done
- Read `HUMAN_TASKS.md` for things that need your attention
