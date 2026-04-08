# Sandbox Notes

Ralph runs with `--dangerously-skip-permissions`. This is required for
autonomous operation but means Claude has full access to everything on
your machine. Huntley's philosophy: "It's not IF it gets popped, it's WHEN."

## Minimum Safety for a Weekend Experiment

**Option A: Just YOLO it (fastest)**
- Run on your main machine
- Make sure nothing sensitive is in the project directory
- Railway deploy token is the only credential exposed
- Accept the risk — it's a weekend project

**Option B: Docker sandbox (recommended)**
```bash
# Run Ralph inside a container with only the project mounted
docker run -it --rm \
  -v $(pwd):/app \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  -e RAILWAY_TOKEN=$RAILWAY_TOKEN \
  -w /app \
  node:20-slim \
  bash -c "npm i -g @anthropic-ai/claude-code && ./loop.sh"
```

**Option C: Dedicated machine**
- Use a Mac Mini, spare laptop, or cloud VM
- SSH in, clone the repo, run the loop
- Monitor from your phone via Railway dashboard
- This is what Huntley does for extended runs

## Credentials Ralph Needs

- `ANTHROPIC_API_KEY` — for Claude Code (or use Claude Max subscription)
- `RAILWAY_TOKEN` — for `railway` CLI pushes (optional if using git-based deploys)
- Git push access to the repo (SSH key or HTTPS token)

## Cost Expectations (Claude Max)

With Max subscription ($100-200/mo), you get substantial Opus usage.
Each Ralph iteration is one context window. A weekend of ~50-100 iterations
should be well within Max limits. Monitor your usage dashboard.

Without Max, API costs for Opus at ~$15/MTok input + $75/MTok output
can add up fast. Budget ~$50-150 for a full weekend of loops.
