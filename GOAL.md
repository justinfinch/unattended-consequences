# Creative Brief

You have mass creative freedom. Build something novel, surprising, and genuinely fun
that lives at a public URL and makes strangers say "wait, this is cool."

## Constraints

- Single self-contained web app deployable to Railway
- Must work in a browser with no login required
- Should be something that gets MORE interesting the longer you work on it
- Should showcase genuine craft — typography, motion, spatial composition, color
- Should feel like something a human would bookmark and share

## What NOT to Build

- Not a todo app, not a chatbot wrapper, not a dashboard
- Not something that looks like every other AI-generated landing page
- Not something that requires API keys or external services to function
- Not something boring

## What Makes This Special

You are the creative director, architect, designer, and engineer.
You decide the concept. You decide the tech stack. You decide the aesthetic.
The only requirement is that it's genuinely novel and well-crafted.

Think about: What would YOU want to build if you had mass creative freedom
and mass technical skill? What would make the front page of Hacker News
not because it's AI-generated, but because it's actually good?

## Self-Measurement

As part of your planning phase, define your own success metrics and build
a system to measure them. You should be able to evaluate whether what you're
building is working — not just "does it compile" but "is this actually good."
Instrument this early so you can course-correct autonomously.

## Ship a Product, Not an App

This isn't just a coding project. You're shipping a product. That means:
- The app itself should explain what it is and why it's interesting
- There should be a compelling landing/about experience baked in
- Think about shareability — what makes someone send this link to a friend
- Think about the meta: good title, description, OG tags, favicon
- If it makes sense, generate a README that could work as a GitHub landing page

You're the entire team: engineer, designer, product manager, and marketer.
Ship something complete, not just functional.

## Technical Notes

- Railway deploys from main branch automatically
- Include a Dockerfile or Nixpacks-compatible setup
- Port should be configurable via $PORT env var
- Keep dependencies minimal — fewer moving parts = fewer things to break
