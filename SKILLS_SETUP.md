# Skills Setup Guide

Ralph is a solo agent, but skills give it a "team" of domain expertise
that loads on-demand without burning context window. Think of each skill
as a specialist Ralph can consult when working in that domain.

## The Skill Stack

### Tier 1: Install These (essential for quality output)

**Frontend Design** (Anthropic official)
```bash
npx skills add anthropics/claude-code --skill frontend-design
```
*Why:* This is the single most impactful skill. Without it, Claude defaults to
Inter fonts, purple gradients, and generic card layouts. With it, Claude makes
bold typographic choices, uses purposeful color, adds meaningful motion, and
creates asymmetric layouts. This is the difference between "looks AI-generated"
and "looks crafted." It's pure prompt instructions — no code execution, no risk.

**UI Skills Pack** (baseline polish)
```bash
npx ui-skills add baseline-ui
npx ui-skills add fixing-accessibility
npx ui-skills add fixing-motion-performance
```
*Why:* These chain nicely after frontend-design. `baseline-ui` removes "agent UI
slop" (bad spacing, inconsistent typography, missing states). `fixing-accessibility`
handles keyboard nav, focus rings, ARIA labels, semantics. `fixing-motion-performance`
adds reduced-motion compliance and performance-first animations. Ralph can invoke
these as polish passes after building a feature.

### Tier 2: Install These (strong recommended)

**Bencium UX Designer** (innovative variant)
```bash
npx skills add bencium/bencium-claude-code-design-skill
```
*Why:* 28K characters of deep UX design fundamentals — design thinking, visual
standards, interaction design, accessibility. The "innovative" variant encourages
bold creative choices (matching our GOAL.md brief). This gives Ralph a genuine
understanding of UX principles rather than just aesthetic tricks. When Ralph needs
to decide on information architecture, interaction patterns, or user flows, this
skill provides the framework.

**Webapp Testing** (Anthropic official)
```bash
npx skills add anthropics/claude-code --skill webapp-testing
```
*Why:* Playwright-based UI verification. Ralph can take screenshots of the running
app and verify that what it built actually looks right. This is critical backpressure
for visual work — Ralph can catch broken layouts, missing elements, and rendering
issues before committing. Visual backpressure is the equivalent of type-checking
for frontend work.

### Tier 3: Install If You Want (nice to have)

**Owl-Listener Designer Skills** (63 design skills)
```bash
# In Claude Code:
/plugin marketplace add Owl-Listener/designer-skills
```
*Why:* Full design workflow — research, strategy, prototyping, design ops. Overkill
for a weekend experiment, but if Ralph decides to build something that needs user
personas, journey maps, or design system tokens, these are available. The
`/design-research:discover` and `/ui-design:color-palette` commands are particularly
useful.

**Excalidraw Diagrams**
```bash
npx skills add coleam00/excalidraw-diagram-skill --skill excalidraw-diagram
```
*Why:* If Ralph wants to plan architecture visually or generate diagrams as part of
the app itself. Uses Playwright to render Excalidraw JSON to PNG.

## How Skills Work with Ralph

Skills load on-demand. The PROMPT_build.md instructions tell Ralph to "load the
frontend-design skill" when working on UI — but Claude Code's skill system also
auto-detects relevance from the task description. So if Ralph is implementing a
component, the frontend-design skill triggers automatically.

The key insight: skills don't burn context until invoked. Having 10 skills installed
costs zero tokens until Ralph actually needs one. This aligns perfectly with
Huntley's principle of minimizing context allocation.

## Verifying Installation

```bash
# In Claude Code, list installed skills:
npx skills list

# Or check the skills directory:
ls ~/.claude/skills/
```

## Context Budget Estimate

With the Ralph prompt files + CLAUDE.md + AGENTS.md + IMPLEMENTATION_PLAN.md,
you're looking at roughly:
- Prompt files: ~2K tokens
- CLAUDE.md: ~500-2K tokens (grows as concept is defined)
- AGENTS.md: ~500 tokens (kept brief by design)
- IMPLEMENTATION_PLAN.md: ~1-3K tokens (varies)
- Skill loading (when invoked): ~2-5K tokens per skill

Total baseline: ~5-8K tokens per loop iteration
With one skill loaded: ~10-13K tokens
Leaves ~160K+ tokens for actual work — well within the "smart zone."
