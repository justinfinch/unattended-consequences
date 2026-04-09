# Creative Brief

## Mission

Research and identify a genuine pain point for small businesses, then build
a web application that solves it. The app should be something a small business
owner would actually pay for.

You are the researcher, product manager, architect, designer, and engineer.
You pick the problem. You design the solution. You build it.

## Engineering Philosophy: Domain-Driven Design

This project follows DDD as practiced by Eric Evans and Vaughn Vernon.
The code should read like the business domain, not like a framework tutorial.

Core principles:

- **Ubiquitous language** — names in code match the business domain exactly.
  If the domain calls it an "invoice," the code calls it an Invoice, not a
  BillingRecord or PaymentDocument.
- **Rich domain models** — behavior lives on entities and aggregates, not in
  anemic service classes. An Order knows how to apply a discount. A Booking
  knows whether it conflicts with another.
- **Bounded contexts** — clear boundaries between subdomains. Each context has
  its own models, language, and rules. Don't let one context leak into another.
- **Domain events** — state changes are explicit events, not side effects.
  OrderPlaced, InvoiceSent, AppointmentCancelled. These drive workflows.
- **Anti-corruption layers** — external services (real or DTU twins) get their
  own translation layer. The domain never speaks in third-party API shapes.

The domain model must be designed before code is written. specs/architecture.md
must include: aggregates, entities, value objects, bounded contexts, and their
relationships.

## Infrastructure Philosophy

- Open-source and self-hosted wherever possible
- When a third-party service is needed (payments, email, OAuth providers),
  build a DTU twin — a behavioral clone of the service's API — to develop
  and test against. Document the real service integration as a human task
  in HUMAN_TASKS.md with clear setup instructions.
- Social auth (Google, GitHub) is acceptable
- The DTU twin sits behind an anti-corruption layer. When a human later
  connects the real service, only the adapter changes — the domain is untouched.

## Deployment

- Railway auto-deploys from main branch
- App must read port from $PORT environment variable
- Include a Dockerfile or Nixpacks-compatible setup
- Keep dependencies minimal

## Product Quality

This isn't just a coding project. Ship a product:

- The app should explain what it is and why it's interesting
- Compelling landing/about experience baked in
- Good title, description, OG tags, favicon
- Think about the first-run experience for a new user
- Craft matters — typography, spacing, color, motion

## Self-Measurement

Define success metrics early based on the problem you choose to solve.
These should be concrete and tied to the domain:

- Does the app actually solve the stated problem end-to-end?
- Can a user complete the core workflow without confusion?
- Is the domain model clean — aggregates cohesive, boundaries clear?
- Are DTU twins faithful enough to develop against with confidence?

## Feedback Loop

After each build iteration, write a brief self-assessment to LOOP_LOG.md:
what was built, what's working, what feels off, what should be next.
This gives future iterations context beyond the task list.

## Human Tasks

Maintain HUMAN_TASKS.md for anything requiring human hands:
account signups, API key creation, DNS configuration, service provider
decisions, OAuth app registration. Include clear step-by-step instructions.
A human will work through this list on their own schedule.
