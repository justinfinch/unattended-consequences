# Operational Guide

## Build & Run

```bash
# Install
npm install

# Run locally (MUST respect $PORT)
PORT=3000 npm start

# Build (for deploy verification)
npm run build

# Run tests
npm test

# Run database migrations
npm run db:migrate

# Generate a migration from schema changes
npm run db:generate
```

## Tech Stack

- **Runtime:** Node.js (LTS) + TypeScript (strict mode)
- **Framework:** Fastify
- **Database:** PostgreSQL (single instance, schema-per-context)
- **ORM:** Drizzle ORM + Drizzle Kit for migrations
- **Frontend:** HTMX + Handlebars (server-rendered), Tailwind CSS
- **Auth:** Lucia (session-based)
- **Testing:** Vitest
- **Validation:** Zod (at API boundary)

## Deployment

- Railway auto-deploys from `product-alpha` branch
- App MUST read port from `$PORT` environment variable
- Dockerfile in project root
- Railway auto-provides: `PORT`, `DATABASE_URL`

## Validation (run before committing)

1. Build passes: `npm run build`
2. App starts on $PORT: `PORT=3000 npm start`
3. Tests pass: `npm test`
4. No lint/type errors

## DDD Structure

```
src/
  shared/               # Shared kernel (base classes, common value objects, infra)
  job-management/       # Core domain — job lifecycle, quoting, scheduling
  billing/              # Supporting — invoices, payments
  customer/             # Supporting — customer records, service locations
  notification/         # Generic — message delivery
  identity/             # Generic — auth, multi-tenancy
  dtu/                  # DTU twins for dev (email, payments, file storage)
```

Each context follows: `domain/` → `application/` → `infrastructure/` → `interface/`

## Bounded Context Schemas

Each context owns its own PostgreSQL schema:
- `identity.*` — users, businesses
- `customer.*` — customers, service_locations
- `job_management.*` — jobs, quotes, notes, photos, materials
- `billing.*` — invoices, payments
- `notification.*` — messages, delivery attempts

Contexts communicate via domain events, never cross-schema joins.

## Operational Notes

(Update with learnings about building/running/debugging)
