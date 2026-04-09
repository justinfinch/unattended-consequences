# Operational Guide

## Build & Run

Not yet configured. Update this once the tech stack is chosen.

```bash
# Install
npm install

# Run locally (MUST respect $PORT)
PORT=3000 npm start

# Build (for deploy verification)
npm run build

# Run tests
npm test
```

## Deployment

- Railway auto-deploys from main branch
- App MUST read port from $PORT environment variable
- Include Dockerfile or ensure Nixpacks auto-detects the stack

## Validation (run before committing)

1. Build passes: `npm run build`
2. App starts on $PORT: `PORT=3000 npm start`
3. Tests pass: `npm test`
4. No lint/type errors

## Operational Notes

(Update with learnings about building/running/debugging)
