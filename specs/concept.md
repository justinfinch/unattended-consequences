# Concept: TradeFlow — Job Management for Service Trades

## The Problem

Small service trade businesses — plumbers, electricians, HVAC technicians,
cleaners, landscapers, handymen — manage their entire operation through a
chaotic mix of paper notebooks, text messages, spreadsheets, and memory.

The typical workflow looks like this:
1. A customer calls or texts about a problem
2. The owner scribbles a note or tries to remember
3. They drive out to assess the work, maybe give a verbal quote
4. If accepted, they schedule the job mentally or on a paper calendar
5. After completing the work, they handwrite an invoice or send a text
6. Payment collection happens informally — cash, Venmo, "I'll mail a check"
7. Follow-up on unpaid work happens when they remember (often never)

**What breaks:**
- Quotes given verbally are forgotten or disputed
- Jobs fall through the cracks between inquiry and scheduling
- No record of what work was done at which property
- Invoices are delayed days or weeks after job completion
- Overdue payments are never followed up on
- Repeat customers get no recognition or history
- The owner has no visibility into how the business is actually performing

**Who experiences it:** Solo operators and micro-teams (1-5 people) running
service trade businesses doing $50K-$500K/year in revenue. They're skilled
tradespeople, not administrators. Every hour spent on paperwork is an hour
not spent earning.

**Why it matters:** These businesses leave significant money on the table —
forgotten follow-ups, uncollected payments, lost repeat business, and
inability to raise prices because they can't demonstrate professional value.

## The Solution

**TradeFlow** is a job management app that tracks the full lifecycle of
service work: from the moment a customer reaches out, through quoting,
scheduling, job execution, invoicing, and payment collection.

### Core Workflows

**1. Job Lifecycle Tracking**
Every piece of work flows through a clear pipeline:
Inquiry → Quote → Scheduled → In Progress → Completed → Invoiced → Paid

The owner always knows what stage every job is in. Nothing falls through
the cracks.

**2. Quick Quoting**
Create professional quotes in under a minute using saved line items and
pricing. Send via email. Customer can accept or request changes. Accepted
quotes flow directly into scheduled jobs.

**3. Simple Scheduling**
A calendar view shows what's scheduled, what's upcoming, and where there
are gaps. No complex resource allocation — just "what am I doing this week?"

**4. Job Documentation**
Record what was done, add photos, note materials used. This becomes the
basis for the invoice AND a history that's useful on return visits.

**5. One-Tap Invoicing**
When a job is done, generate an invoice from the job record. Line items
come from the quote (adjusted for actual work). Send immediately — no
delay between finishing work and asking for payment.

**6. Payment Tracking**
Know who's paid, who hasn't, and how overdue they are. Simple follow-up
reminders. Cash, check, and digital payments all tracked.

**7. Customer History**
Every customer has a complete history: all jobs, quotes, invoices, notes,
and property details. When Mrs. Johnson calls again, you know exactly what
you did last time.

### Key Differentiators

- **Speed over features:** Optimized for a tradesperson on a job site with
  dirty hands and five minutes between tasks. Not a desk worker with time
  to fill out forms.
- **Job-centric, not accounting-centric:** The job is the organizing concept,
  not the invoice. Invoicing is a natural consequence of completing work.
- **Right-sized:** Not a $39/mo enterprise tool. Not a generic invoice app.
  Purpose-built for the service trade workflow.
- **Opinionated workflow:** The app guides work through the pipeline rather
  than offering infinite configurability. Fewer choices, faster action.

## Why This Problem

### Over Alternatives

| Candidate | Why Not |
|---|---|
| Invoice/Quote Management | Saturated market (Wave free, FreshBooks $17/mo). Weak standalone without accounting. |
| Appointment Booking | Requires calendar sync to be useful. Shallow domain model. Calendly is free. |
| Inventory Management | Real problem but CRUD-heavy. Less behavioral richness for DDD. |
| Pipeline/CRM | Too thin for 50-100 iterations. HubSpot CRM is free. |
| Vendor/Supplier PO | Niche audience. Most micro-businesses don't have enough volume. |

### Why Job Management Wins

1. **Domain richness** — The job lifecycle is a natural fit for DDD with
   rich state machines, meaningful domain events, and non-obvious aggregate
   boundaries. Real modeling decisions that reward careful design.

2. **Standalone value** — A tradesperson replacing paper with this tool gets
   immediate value with zero integrations. The tool IS the system of record.

3. **Willingness to pay** — Service trades are revenue-generating businesses.
   Jobber charges $39-$249/mo. ServiceTitan won't show pricing. There's a
   massive gap between "free spreadsheet" and these enterprise tools.

4. **Scope fit** — The job lifecycle provides natural incremental layers:
   job tracking → quoting → scheduling → invoicing → customer history.
   Each adds genuine value and domain complexity.

## Success Criteria

1. **End-to-end job lifecycle:** A user can take a job from initial inquiry
   through to paid invoice without leaving the app.
2. **Speed:** Creating a quote takes under 60 seconds. Converting a completed
   job to an invoice takes one click.
3. **Clarity:** At any moment, the user can see all active jobs and their
   status, all unpaid invoices, and this week's schedule.
4. **Domain integrity:** The domain model is clean — aggregates are cohesive,
   bounded contexts have clear boundaries, events drive workflows naturally.
5. **Professional output:** Quotes and invoices look professional enough that
   customers take the business seriously.
