# Implementation Plan

**TradeFlow** is a job management app for small service trade businesses
(plumbers, electricians, cleaners). It tracks the full lifecycle of service
work — from customer inquiry through quoting, scheduling, job execution,
invoicing, and payment collection. Built with Domain-Driven Design, deployed
on Railway.

---

## Phase 1 — Deployable Skeleton

Get the app running on Railway with the DDD project structure, database
connection, authentication, and a landing page.

### 1.1 Project Setup
- [ ] Initialize Node.js project with TypeScript, Fastify, and build scripts
- [ ] Configure `tsconfig.json` with strict mode and path aliases
- [ ] Set up Tailwind CSS build pipeline
- [ ] Create `Dockerfile` that respects `$PORT` environment variable
- [ ] Create `railway.json` with deploy configuration
- [ ] Add `vitest.config.ts` for test runner

### 1.2 DDD Foundation (Shared Kernel)
- [ ] Create `src/shared/domain/Entity.ts` — base entity with ID and equality
- [ ] Create `src/shared/domain/AggregateRoot.ts` — extends entity with domain event collection
- [ ] Create `src/shared/domain/ValueObject.ts` — base value object with structural equality
- [ ] Create `src/shared/domain/DomainEvent.ts` — event interface with timestamp and aggregate ID
- [ ] Create shared value objects: `Money`, `Address`, `EmailAddress`, `PhoneNumber`, `PersonName`
- [ ] Create branded types: `BusinessId`, `UserId`, `JobId`, `CustomerId`, etc.

### 1.3 Infrastructure Foundation
- [ ] Set up PostgreSQL connection with Drizzle ORM (`src/shared/infrastructure/db.ts`)
- [ ] Create database schemas for each bounded context (job_management, billing, customer, identity, notification)
- [ ] Implement in-process `EventBus` for domain event dispatch
- [ ] Set up `UnitOfWork` for transaction management

### 1.4 Identity Context (Auth)
- [ ] Define `User` and `Business` aggregates in identity domain
- [ ] Create Drizzle schema for `identity.users` and `identity.businesses` tables
- [ ] Set up Lucia authentication with session-based auth
- [ ] Implement `RegisterBusiness` command (creates business + owner user)
- [ ] Implement `Login` command
- [ ] Create registration and login pages (Handlebars templates)
- [ ] Add auth middleware for tenant isolation (BusinessId on every request)

### 1.5 App Shell and Landing
- [ ] Set up Fastify app with plugin architecture (`src/app.ts`)
- [ ] Create server entry point reading `$PORT` (`src/server.ts`)
- [ ] Set up Handlebars templating with layouts (main app, public)
- [ ] Create shared partials (nav, status badges)
- [ ] Build landing page — explains what TradeFlow is, registration CTA
- [ ] Build dashboard skeleton — placeholder for today's schedule and action items
- [ ] Set up HTMX for dynamic updates
- [ ] Add health check endpoint (`GET /health`)
- [ ] Configure favicon and OG meta tags

### 1.6 Deploy Verification
- [ ] Verify `npm run build` succeeds
- [ ] Verify `PORT=3000 npm start` serves the app
- [ ] Verify Docker build succeeds
- [ ] Verify health check returns 200
- [ ] Run first deployment to Railway (human task)

---

## Phase 2 — Core Domain

Build the Job Management and Customer contexts end-to-end: creating jobs,
attaching quotes, scheduling, completing work, and managing customers.

### 2.1 Customer Context
- [ ] Implement `Customer` aggregate root with domain logic
- [ ] Implement `ServiceLocation` entity
- [ ] Implement `ContactMethod` value object
- [ ] Create Drizzle schema for `customer.*` tables
- [ ] Implement `CustomerRepository`
- [ ] Build `CreateCustomer` command
- [ ] Build `UpdateCustomer` command
- [ ] Build `AddServiceLocation` command
- [ ] Build `ListCustomers` and `GetCustomer` queries
- [ ] Build `SearchCustomers` query (name, phone search)
- [ ] Create customer list page with search
- [ ] Create customer detail page with service locations
- [ ] Create new customer form
- [ ] Write domain model unit tests for Customer aggregate

### 2.2 Job Management — Core Aggregate
- [ ] Implement `Job` aggregate root with full state machine
- [ ] Implement `JobStatus` with transition validation
- [ ] Implement `JobNote`, `Photo`, `Material` entities
- [ ] Implement `LineItem`, `ScheduleSlot` value objects
- [ ] Create Drizzle schema for `job_management.*` tables
- [ ] Implement `JobRepository` with aggregate reconstitution
- [ ] Wire domain events: `InquiryReceived`, `JobScheduled`, `JobStarted`, `JobCompleted`, `JobLost`
- [ ] Write domain model unit tests for Job aggregate (state machine transitions, invariants)

### 2.3 Job Management — Commands and Queries
- [ ] Build `CreateJob` command (new inquiry)
- [ ] Build `ScheduleJob` command
- [ ] Build `StartJob` command
- [ ] Build `CompleteJob` command
- [ ] Build `AddJobNote` command
- [ ] Build `AddPhoto` command (with file upload)
- [ ] Build `RecordMaterial` command
- [ ] Build `ListJobs` query (with status filter)
- [ ] Build `GetJob` query (full aggregate with notes, photos, materials)
- [ ] Build `GetJobsByStatus` query
- [ ] Build `GetSchedule` query (jobs for a date range)

### 2.4 Job Management — Quoting
- [ ] Implement `Quote` entity (child of Job) with status machine
- [ ] Implement `QuoteStatus` with transitions
- [ ] Build `AttachQuote` command (add quote with line items to job)
- [ ] Build `SendQuote` command (marks quote as sent, triggers notification)
- [ ] Build `AcceptQuote` command (customer accepts, job advances)
- [ ] Build `RejectQuote` command
- [ ] Wire `QuoteAttached`, `QuoteSent`, `QuoteAccepted`, `QuoteRejected` events
- [ ] Write unit tests for quote lifecycle within Job aggregate

### 2.5 Job Management — UI
- [ ] Build job list page with status filter tabs
- [ ] Build job detail page showing full job information
- [ ] Build new job form (select/create customer, add title, description)
- [ ] Build quote builder UI (add/remove line items, calculate total)
- [ ] Build schedule view (week calendar showing jobs by date)
- [ ] Build job status transition controls (contextual action buttons)
- [ ] Build job notes section with add note form
- [ ] Build photo upload and gallery
- [ ] Build materials recording UI
- [ ] Add HTMX for inline status changes and live updates

### 2.6 Dashboard
- [ ] Build today's schedule section (today's jobs with status)
- [ ] Build action items section (quotes to send, jobs to schedule)
- [ ] Build quick stats (jobs this week, active jobs count)
- [ ] Build recent activity feed from domain events

---

## Phase 3 — Billing and Notifications

Build the Billing context (invoices, payments) and Notification context
(email delivery via DTU twins).

### 3.1 Billing — Invoice Aggregate
- [ ] Implement `Invoice` aggregate root with state machine
- [ ] Implement `InvoiceLine` entity and `Payment` entity
- [ ] Implement `InvoiceNumber` value object (sequential per business)
- [ ] Implement `InvoiceStatus` with transition validation
- [ ] Implement `PaymentMethod` enum
- [ ] Create Drizzle schema for `billing.*` tables
- [ ] Implement `InvoiceRepository`
- [ ] Wire domain events: `InvoiceCreated`, `InvoiceSent`, `PaymentRecorded`, `InvoicePaid`, `InvoiceOverdue`, `InvoiceVoided`
- [ ] Write domain model unit tests for Invoice aggregate

### 3.2 Billing — Commands and Queries
- [ ] Build `CreateInvoiceFromJob` command (seeded from job data via event handler)
- [ ] Build `SendInvoice` command
- [ ] Build `RecordPayment` command (manual payment recording)
- [ ] Build `VoidInvoice` command
- [ ] Build `CheckOverdueInvoices` command (scheduled/periodic)
- [ ] Build `ListInvoices` query (with status filter)
- [ ] Build `GetInvoice` query
- [ ] Build `GetOutstandingBalance` query
- [ ] Implement `OnJobCompleted` event handler (auto-creates draft invoice)

### 3.3 Billing — UI
- [ ] Build invoice list page with status filters
- [ ] Build invoice detail page with payment history
- [ ] Build invoice editor (adjust line items before sending)
- [ ] Build record payment form
- [ ] Build printable/PDF invoice view
- [ ] Add overdue indicators on dashboard and invoice list
- [ ] Build invoice status transition controls

### 3.4 Notification Context
- [ ] Implement `Message`, `Recipient`, `DeliveryAttempt` domain objects
- [ ] Implement `EmailGateway` port interface
- [ ] Build `SendMessage` command
- [ ] Build event handlers: `OnQuoteSent`, `OnInvoiceSent`, `OnInvoiceOverdue`

### 3.5 DTU Twins
- [ ] Build `DtuEmailGateway` — stores emails in database, always succeeds
- [ ] Build DTU email debug viewer (`/dtu/emails`) — view all sent emails in dev
- [ ] Build `DtuFileStore` — local file storage for job photos
- [ ] Build `DtuPaymentGateway` — fake payment links and simulation page
- [ ] Configure DTU/production adapter switching via environment variable

### 3.6 Cross-Context Event Wiring
- [ ] Wire `JobCompleted` → Billing `OnJobCompleted` (creates draft invoice)
- [ ] Wire `QuoteSent` → Notification `OnQuoteSent` (sends email)
- [ ] Wire `InvoiceSent` → Notification `OnInvoiceSent` (sends email)
- [ ] Wire `InvoiceOverdue` → Notification `OnInvoiceOverdue` (sends reminder)
- [ ] Wire `InvoicePaid` → Customer `OnInvoicePaid` (updates lifetime value)
- [ ] Wire `JobCompleted` → Customer `OnJobCompleted` (updates history)
- [ ] Create `src/event-wiring.ts` to centralize all subscriptions

---

## Phase 4 — Polish and Product Quality

Make TradeFlow feel like a product, not a demo. First-run experience,
professional design, performance, and edge cases.

### 4.1 First-Run Experience
- [ ] Guided onboarding after registration (set up business info, trade type)
- [ ] Empty states for all list views with helpful CTAs
- [ ] Sample data option for testing ("Create demo job")
- [ ] Quick-start tutorial: create first customer, create first job

### 4.2 Landing Page
- [ ] Compelling hero section explaining the value proposition
- [ ] Feature highlights with icons
- [ ] "Built for trades" messaging — not generic SaaS
- [ ] Call-to-action: sign up free
- [ ] Proper OG tags, meta description, title

### 4.3 Design Polish
- [ ] Review all pages against aesthetic spec (typography, spacing, colors)
- [ ] Ensure all status badges use consistent color scheme
- [ ] Polish form interactions (validation feedback, success states)
- [ ] Add loading indicators for all HTMX requests
- [ ] Review and fix mobile responsiveness across all pages
- [ ] Add empty state illustrations/icons

### 4.4 Performance and Reliability
- [ ] Add database indexes for common queries (jobs by status, by customer, by date)
- [ ] Add request logging middleware
- [ ] Add error handling middleware with user-friendly error pages
- [ ] Review all domain invariants for edge cases
- [ ] Add database migration strategy documentation

### 4.5 Saved Line Items (Productivity Feature)
- [ ] Build a "service catalog" — saved line items the business reuses
- [ ] Allow quick-add from catalog when building quotes
- [ ] Manage catalog from settings page

### 4.6 Customer History Read Model
- [ ] Build customer history timeline (all jobs, invoices, payments)
- [ ] Show lifetime value per customer
- [ ] Show last service date and location
- [ ] Link from customer detail to related jobs and invoices
