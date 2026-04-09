# Ralph Weekend Experiment

Autonomous creative coding loop using the Ralph Wiggum technique.
Claude gets full creative freedom to build something novel, deployed to Railway.

## Quick Start

```bash
# 1. Create a new repo and clone it
gh repo create unattended-consequences --public --clone
cd unattended-consequences

# 2. Copy these files into the repo
# (copy all files from this scaffold)

# 3. Install skills (see below)

# 4. Initialize git + Railway
git init && git add -A && git commit -m "initial scaffold"
railway link   # or railway init

# 5. Run Ralph
chmod +x loop.sh
./loop.sh plan        # First: let Claude plan what to build
./loop.sh             # Then: let Claude build it
```

## Plugins to Install

These give Ralph a "team" of domain expertise to draw on automatically.
Install from within Claude Code using `/plugin install`.

### Required

```
# Feature development workflow — explore, architect, implement, review
/plugin install feature-dev@claude-plugins-official --scope project

# Frontend design — prevents generic AI aesthetic, adds bold design choices
/plugin install frontend-design@claude-plugins-official --scope project
```

## File Structure

```
unattended-consequences/
├── loop.sh                    # The Ralph loop script
├── PROMPT_plan.md             # Planning mode prompt
├── PROMPT_build.md            # Building mode prompt
├── CLAUDE.md                  # Project context (Claude updates this)
├── AGENTS.md                  # Operational guide (Claude updates this)
├── IMPLEMENTATION_PLAN.md     # Task list (Claude generates/updates)
├── GOAL.md                    # Creative brief — the only human input
├── railway.json               # Railway deployment config
├── .claude/
│   └── settings.local.json    # Claude Code permissions
└── README.md                  # This file
```

## How It Works

1. `loop.sh plan` — Claude reads GOAL.md, decides what to build, writes specs + plan
2. `loop.sh` — Claude reads plan, picks most important task, builds it, commits, pushes
3. Railway auto-deploys from main
4. Repeat until you wake up and check the URL

## Monitoring

- Watch `ralph.log` for real-time output
- Check Railway dashboard for deploy status
- Read `IMPLEMENTATION_PLAN.md` to see what Claude has been doing
- Read `CLAUDE.md` for Claude's self-documented learnings

## Emergency Controls

- `Ctrl+C` — stop the loop
- `git reset --hard HEAD~N` — revert N commits
- `./loop.sh plan` — regenerate the plan from scratch
- Delete `IMPLEMENTATION_PLAN.md` and re-plan if Ralph goes off the rails
