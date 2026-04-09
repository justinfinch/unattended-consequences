# TradeFlow — Aesthetic Direction

## Design Philosophy

TradeFlow is used by tradespeople — plumbers, electricians, cleaners — often
on a job site, often on a phone, often with dirty hands. The UI must be:

1. **Fast to scan** — status and next actions visible at a glance
2. **Big touch targets** — designed for thumbs, not cursors
3. **Low cognitive load** — no training needed, no hidden menus
4. **Professional but not corporate** — trustworthy, not sterile

The aesthetic should feel like a well-made tool: sturdy, reliable, no-nonsense.
Think of a quality measuring tape, not a productivity SaaS dashboard.

## Typography

**Primary font:** Inter (system font stack fallback: -apple-system, system-ui, sans-serif)

Inter is highly legible at all sizes, works well on mobile, and has excellent
number rendering — important for an app that shows prices, quantities, and dates
constantly.

**Scale:**
| Use | Size | Weight |
|---|---|---|
| Page title | 24px / 1.5rem | 700 (Bold) |
| Section header | 18px / 1.125rem | 600 (Semibold) |
| Body / form labels | 16px / 1rem | 400 (Regular) |
| Secondary text | 14px / 0.875rem | 400 (Regular) |
| Badges / captions | 12px / 0.75rem | 500 (Medium) |

**Minimum touch text:** 16px. Never put actionable text below 14px on mobile.

## Color Palette

A warm, grounded palette that avoids the cold blue/white of enterprise SaaS.
Inspired by workshop environments — slate, amber, and natural greens.

### Core Colors

| Name | Hex | Tailwind | Use |
|---|---|---|---|
| Slate 900 | #0f172a | `slate-900` | Primary text |
| Slate 700 | #334155 | `slate-700` | Secondary text |
| Slate 100 | #f1f5f9 | `slate-100` | Page background |
| White | #ffffff | `white` | Card/surface background |

### Accent Colors

| Name | Hex | Tailwind | Use |
|---|---|---|---|
| Amber 500 | #f59e0b | `amber-500` | Primary action, brand accent |
| Amber 600 | #d97706 | `amber-600` | Hover/active state |
| Amber 50 | #fffbeb | `amber-50` | Light accent background |

### Status Colors

| Status | Color | Tailwind | Hex |
|---|---|---|---|
| Inquiry | Blue 500 | `blue-500` | #3b82f6 |
| Quoted | Purple 500 | `purple-500` | #8b5cf6 |
| Scheduled | Amber 500 | `amber-500` | #f59e0b |
| In Progress | Orange 500 | `orange-500` | #f97316 |
| Completed | Green 500 | `green-500` | #22c55e |
| Lost | Slate 400 | `slate-400` | #94a3b8 |
| Overdue | Red 500 | `red-500` | #ef4444 |
| Paid | Emerald 600 | `emerald-600` | #059669 |

### Semantic Colors

| Purpose | Color | Tailwind |
|---|---|---|
| Success | Green 600 | `green-600` |
| Warning | Amber 500 | `amber-500` |
| Error / Destructive | Red 600 | `red-600` |
| Info | Blue 500 | `blue-500` |

## Spacing System

Use Tailwind's default 4px grid. Key spacings:

| Context | Space | Tailwind |
|---|---|---|
| Inside cards / form groups | 16px | `p-4` |
| Between cards | 16px | `gap-4` |
| Page padding (mobile) | 16px | `px-4` |
| Page padding (desktop) | 32px | `px-8` |
| Section spacing | 32px | `space-y-8` |
| Between form fields | 12px | `space-y-3` |
| Button padding | 12px / 16px | `px-4 py-3` |

Generous spacing throughout — this isn't a data-dense analytics dashboard.
Breathable layouts that are easy to scan.

## Component Patterns

### Cards

The primary content container. Jobs, invoices, and customers are all displayed
as cards.

```
┌─────────────────────────────────────┐
│ [Status Badge]                      │
│ Job Title                     $450  │
│ Customer Name · 123 Oak St          │
│ Scheduled: Mar 15, 2pm              │
│                        [Action Btn] │
└─────────────────────────────────────┘
```

- White background, subtle shadow (`shadow-sm`), rounded corners (`rounded-lg`)
- Status badge in top-left, prominent
- Key info scannable without tapping
- Primary action accessible without opening the detail view

### Status Badges

Pill-shaped, colored backgrounds with white or dark text. Large enough to
tap as a filter.

```
[● Inquiry]  [● Quoted]  [● Scheduled]  [● In Progress]  [● Completed]
```

- Background uses the status color at 10% opacity
- Text uses the full status color
- Small dot indicator for at-a-glance status

### Forms

- Labels above inputs (never floating/inline labels)
- Large input fields: min 48px height for touch
- Clear error states: red border + message below field
- Primary submit button: full-width on mobile, amber background
- Minimal required fields — don't ask for information you don't need yet

### Navigation

**Mobile (primary):** Bottom tab bar with 4-5 tabs
- Dashboard (home icon)
- Jobs (briefcase icon)
- Schedule (calendar icon)
- Invoices (receipt icon)
- More (menu icon — customers, settings)

**Desktop:** Left sidebar with the same navigation items expanded.

The nav should feel like a native app, not a website. Current page is clearly
highlighted with the amber accent.

### Dashboard

The first screen after login. Shows:
1. **Today's schedule** — what jobs are happening today
2. **Action items** — quotes to send, invoices to follow up on
3. **Quick stats** — jobs this week, outstanding invoices, revenue
4. **Recent activity** — last few status changes

Not a analytics dashboard. A "what do I need to do right now?" screen.

### Tables (Invoice List, Customer List)

- Responsive: full table on desktop, card list on mobile
- Sortable columns: tap header to sort
- Status filter bar above the table
- Key actions (view, send, record payment) accessible without opening detail

### Empty States

When a section has no data yet, show:
- A simple illustration or icon (not stock photos)
- A one-line explanation of what goes here
- A CTA button to create the first item

Empty states are teaching moments. "No jobs yet. Create your first job to
start tracking your work."

## Motion and Interaction

### Transitions
- Page transitions: none (HTMX swaps content, no route animations)
- Status changes: brief color fade (150ms ease)
- Card hover (desktop): subtle lift (`hover:shadow-md`)
- Dropdown/modal: fade in (100ms)

### Loading States
- HTMX indicator: small spinner in the nav bar, not blocking overlays
- Skeleton screens for card lists on initial load
- Optimistic UI for status changes (show the change, revert on error)

### Feedback
- Success: brief green toast notification, auto-dismiss after 3s
- Error: red toast, stays until dismissed
- No modals for confirmation — use inline confirms ("Are you sure? [Yes] [Cancel]")

## Responsive Approach

**Mobile-first.** The app must be fully functional on a 375px-wide phone screen.

| Breakpoint | Width | Layout |
|---|---|---|
| Mobile | < 768px | Single column, bottom nav, cards stacked |
| Tablet | 768-1024px | Two columns where useful, bottom nav |
| Desktop | > 1024px | Sidebar nav, multi-column layouts |

No features are hidden on mobile. No "please use desktop for full experience"
messages. Mobile is the primary experience.

## Brand Identity

### Name: TradeFlow

Conveys movement, progress, workflow — the flow of jobs through the business.
Short, memorable, no jargon.

### Logo Direction

Simple wordmark. "Trade" in semibold, "Flow" in regular weight. The amber
accent color on "Flow" to suggest movement. No icon/logomark needed initially —
the wordmark is the brand.

### Voice and Tone

- Direct and clear, never cute or clever
- Use trade language where appropriate ("job" not "project", "quote" not "proposal")
- Numbers are prominent — money, dates, counts always visible
- Encourage without being patronizing

### OG Tags / Meta

```
title: "TradeFlow — Job Management for Service Trades"
description: "Track jobs from inquiry to payment. Built for plumbers, electricians, and service businesses who want to stop losing track of work."
```
