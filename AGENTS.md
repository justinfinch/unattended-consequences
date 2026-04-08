# Operational Guide

## Build & Run

Not yet configured. Update this file once the tech stack is chosen.

Expected pattern:
```bash
# Install dependencies
npm install   # or pip install, cargo build, etc.

# Run locally
PORT=3000 npm start   # must respect $PORT env var for Railway

# Run tests
npm test
```

## Deployment

- Platform: Railway (auto-deploys from main branch)
- The app MUST read the port from `$PORT` environment variable
- Include a Dockerfile or ensure Nixpacks can auto-detect the stack
- Health check: Railway will hit the root URL

## Validation Checklist (run before committing)

1. App builds without errors
2. App starts and responds on $PORT
3. Tests pass (if tests exist)
4. No TypeScript/lint errors (if applicable)

## Operational Notes

(Update this section with learnings about how to build/run/debug the project)
