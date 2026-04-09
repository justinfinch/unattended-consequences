# TradeFlow — Domain Architecture

## Design Philosophy

TradeFlow is **job-centric**. The Job aggregate is the gravitational center of the
system. Quotes exist to win jobs. Invoices exist to collect payment for jobs.
Schedules exist to plan jobs. Customer records exist to contextualize jobs.

Every design decision flows from this: the Job is the unit of work, the unit of
value, and the organizing concept a tradesperson thinks in.

---

## 1. Bounded Contexts

### 1.1 Job Management (Core Domain)

**Purpose:** Tracks the full lifecycle of a unit of work from first contact through
completion. This is the heart of TradeFlow — the place where domain complexity lives.

**Ubiquitous Language:**
- **Job** — A discrete unit of service work for a customer at a location
- **Inquiry** — A customer's initial request for work (the starting state)
- **Job Status** — The current pipeline stage (Inquiry, Quoted, Scheduled, InProgress, Completed)
- **Job Note** — A timestamped observation recorded during any phase
- **Photo** — A captured image documenting work conditions or results
- **Material** — A supply item used during job execution with quantity and cost
- **Line Item** — A billable entry (labor, materials, flat-rate service)
- **Schedule Slot** — A date/time window assigned to a job

**Relationships:**
- Publishes events consumed by Billing (JobCompleted, QuoteAccepted)
- Publishes events consumed by Customer (JobCompleted, InquiryReceived)
- Consumes Customer context for customer identity resolution

### 1.2 Billing (Supporting Domain)

**Purpose:** Handles the financial lifecycle after work is done — invoice generation,
delivery, payment tracking, and overdue follow-up. Deliberately separated from Job
Management because the language shifts: we stop talking about "work" and start talking
about "money owed."

**Ubiquitous Language:**
- **Invoice** — A request for payment tied to completed work
- **Invoice Line** — A single charge entry on an invoice
- **Payment** — A recorded receipt of money (cash, check, digital)
- **Payment Method** — How the customer paid (Cash, Check, BankTransfer, CardOnline)
- **Outstanding Balance** — The unpaid remainder on an invoice
- **Overdue** — An invoice past its due date with outstanding balance
- **Follow-Up** — An action taken to pursue an overdue payment

**Relationships:**
- Subscribes to Job Management events (JobCompleted triggers invoice draft creation)
- Publishes events consumed by Notification (InvoiceSent, PaymentOverdue)
- References Customer context for billing address and contact info

### 1.3 Customer (Supporting Domain)

**Purpose:** Maintains the identity, contact details, service locations, and
cross-job history for each customer. This is a shared concept — both Job Management
and Billing need customer data — but the Customer context owns the truth.

**Ubiquitous Language:**
- **Customer** — A person or entity who requests and pays for service work
- **Service Location** — A physical address where work is performed (a customer may have multiple)
- **Contact Method** — How the customer prefers to be reached (phone, email, text)
- **Customer History** — The complete record of interactions across all jobs

**Relationships:**
- Provides customer identity to Job Management and Billing via published read model
- Subscribes to Job Management events to build customer history automatically

### 1.4 Notification (Generic Subdomain)

**Purpose:** Delivers messages to customers and the business owner through external
channels. This context knows nothing about jobs or invoices — it receives a
"send this message to this recipient" command and handles delivery.

**Ubiquitous Language:**
- **Message** — Content to be delivered to a recipient
- **Recipient** — Contact details for delivery (email address, phone number)
- **Channel** — Delivery mechanism (Email, SMS)
- **Delivery Attempt** — A single try at delivering a message
- **Delivery Status** — Whether the attempt succeeded, failed, or is pending

**Relationships:**
- Subscribes to events from Billing (InvoiceSent, PaymentOverdue)
- Subscribes to events from Job Management (QuoteSent)
- Uses ACL to communicate with external email/SMS providers (or DTU twins)

### 1.5 Identity (Generic Subdomain)

**Purpose:** Authentication and authorization. Who is using the system and what
business do they belong to? Minimal — this is a solved problem, not a place to
invest domain modeling effort.

**Ubiquitous Language:**
- **User** — A person who logs into TradeFlow
- **Business** — The trade business entity (tenant). All data is scoped to a business.
- **Role** — Owner or Team Member (only two roles — keep it simple for micro-teams)

**Relationships:**
- Provides identity context to all other bounded contexts
- Every aggregate in the system carries a BusinessId for tenant isolation

---

## 2. Aggregates and Entities

### 2.1 Job (Aggregate Root) — Job Management Context

The central aggregate. A Job is the domain's primary consistency boundary.

**Root Entity: Job**
| Field | Type | Notes |
|---|---|---|
| id | JobId (UUID) | |
| businessId | BusinessId | Tenant isolation |
| customerId | CustomerId | Reference to Customer context |
| locationId | ServiceLocationId | Where the work happens |
| title | string | Short description ("Fix leaking kitchen faucet") |
| status | JobStatus | State machine (see below) |
| quote | Quote (entity) | Optional — embedded, not a separate aggregate |
| scheduleSlot | ScheduleSlot (VO) | When the work is planned |
| notes | JobNote[] | Timestamped observations |
| photos | Photo[] | Documentation images |
| materials | Material[] | Supplies used |
| createdAt | Timestamp | |
| updatedAt | Timestamp | |

**Key Decision: Quote is embedded inside Job, not a separate aggregate.**

Rationale: In the service trade domain, a quote does not have an independent lifecycle.
A quote always exists in the context of a specific job for a specific customer at a
specific location. Tradespeople don't think "I have 12 quotes" — they think "I have
12 jobs, some of which I've quoted." The quote is a phase of the job, not a separate
concept.

This means: you cannot create a quote without creating a job first. An inquiry arrives,
a Job is created in Inquiry status, and then a quote is attached to it. If the quote
is rejected, the Job moves to Lost. If accepted, the Job moves to Scheduled.

**Exception case:** "Emergency work with no quote" — the Job skips the Quoted state
entirely, going Inquiry -> Scheduled or Inquiry -> InProgress directly. The model
supports this because quote is optional.

**Child Entity: Quote**
| Field | Type | Notes |
|---|---|---|
| id | QuoteId (UUID) | |
| lineItems | LineItem[] | What's being charged for |
| totalAmount | Money | Computed from line items |
| validUntil | Date | Expiration date |
| status | QuoteStatus | Draft, Sent, Accepted, Rejected, Expired |
| sentAt | Timestamp? | When sent to customer |
| respondedAt | Timestamp? | When customer responded |

**Child Entity: JobNote**
| Field | Type | Notes |
|---|---|---|
| id | NoteId (UUID) | |
| content | string | Free text |
| authorId | UserId | Who wrote it |
| createdAt | Timestamp | |

**Child Entity: Photo**
| Field | Type | Notes |
|---|---|---|
| id | PhotoId (UUID) | |
| storageKey | string | Reference to file storage |
| caption | string? | Optional description |
| takenAt | Timestamp | |

**State Machine: Job Status**

```
                    ┌──────────┐
                    │  Inquiry  │
                    └────┬─────┘
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
         ┌────────┐ ┌────────┐ ┌──────┐
         │ Quoted │ │Scheduled│ │ Lost │
         └───┬────┘ └───┬────┘ └──────┘
             │          │
     ┌───────┼───┐      │
     ▼       ▼   ▼      │
┌────────┐ ┌────┐│      │
│Scheduled│ │Lost││      │
└───┬────┘ └────┘│      │
    │             │      │
    ▼             │      ▼
┌──────────┐     │  ┌──────────┐
│InProgress │◄───┘  │InProgress │
└────┬─────┘       └────┬─────┘
     │                   │
     ▼                   ▼
┌──────────┐       ┌──────────┐
│ Completed │       │ Completed │
└──────────┘       └──────────┘
```

Valid transitions:
- **Inquiry -> Quoted**: Quote attached to job
- **Inquiry -> Scheduled**: Emergency/repeat work, no quote needed
- **Inquiry -> Lost**: Customer never responded or declined before quote
- **Quoted -> Scheduled**: Quote accepted, work scheduled
- **Quoted -> Lost**: Quote rejected or expired
- **Scheduled -> InProgress**: Work begins
- **InProgress -> Completed**: Work finished
- **Completed** is terminal within this context. Billing takes over.

**Invariants:**
1. A Job cannot move to Scheduled without a ScheduleSlot
2. A Job cannot move to Quoted without a Quote with at least one LineItem
3. A Job cannot move to Completed from any state other than InProgress
4. A Quote can only be Accepted if its status is Sent and it hasn't expired
5. Once a Job is Completed, its quote and materials are frozen (no edits)
6. A Job always belongs to exactly one Customer and one ServiceLocation

### 2.2 Invoice (Aggregate Root) — Billing Context

**Root Entity: Invoice**
| Field | Type | Notes |
|---|---|---|
| id | InvoiceId (UUID) | |
| businessId | BusinessId | Tenant isolation |
| jobId | JobId | The completed job this invoice covers |
| customerId | CustomerId | Who owes the money |
| invoiceNumber | InvoiceNumber (VO) | Human-readable sequential number (e.g., INV-0042) |
| lineItems | InvoiceLine[] | Charges — seeded from job quote/materials, editable |
| totalAmount | Money | Computed from line items |
| issuedAt | Timestamp | When the invoice was created |
| dueDate | Date | When payment is expected |
| status | InvoiceStatus | Draft, Sent, Paid, Overdue, Void |
| payments | Payment[] | Partial or full payments received |

**Key Decision: Invoice is a separate aggregate from Job, in a separate bounded context.**

Rationale: Once work is done, the financial conversation has different rules, different
invariants, and different language. An invoice can be voided and reissued. Partial
payments are tracked. Due dates and overdue logic have nothing to do with plumbing.
The consistency boundary is different: Job cares about "is the work done right?"
Invoice cares about "has the money been collected?"

The Invoice is seeded from Job data (quote line items, materials) via the
JobCompleted event, but it then lives independently. The business owner can adjust
line items on the invoice without affecting the job record. This matches reality:
"I quoted $200 but the job took longer, so I'm invoicing $250."

**Child Entity: InvoiceLine**
| Field | Type | Notes |
|---|---|---|
| id | InvoiceLineId (UUID) | |
| description | string | What the charge is for |
| quantity | Quantity | How much |
| unitPrice | Money | Price per unit |
| total | Money | quantity * unitPrice |

**Child Entity: Payment**
| Field | Type | Notes |
|---|---|---|
| id | PaymentId (UUID) | |
| amount | Money | How much was paid |
| method | PaymentMethod | Cash, Check, BankTransfer, CardOnline |
| receivedAt | Timestamp | When the payment was received |
| note | string? | Optional ("Check #4521") |

**State Machine: Invoice Status**

```
┌───────┐     ┌──────┐     ┌──────┐
│ Draft │ ──► │ Sent │ ──► │ Paid │
└───┬───┘     └──┬───┘     └──────┘
    │            │
    ▼            ▼
┌──────┐    ┌─────────┐
│ Void │    │ Overdue  │ ──► Paid
└──────┘    └─────────┘
                 │
                 ▼
              ┌──────┐
              │ Void │
              └──────┘
```

Valid transitions:
- **Draft -> Sent**: Invoice delivered to customer
- **Draft -> Void**: Invoice cancelled before sending
- **Sent -> Paid**: Full payment received (or partial payments sum to total)
- **Sent -> Overdue**: Due date passed with outstanding balance (system-driven)
- **Overdue -> Paid**: Late payment received
- **Overdue -> Void**: Debt written off

**Invariants:**
1. An Invoice must have at least one InvoiceLine
2. Total payments cannot exceed the invoice totalAmount
3. Status transitions to Paid only when outstanding balance is zero
4. InvoiceNumber is unique within a Business and monotonically increasing
5. A Void invoice cannot accept payments
6. An Invoice references exactly one JobId (one invoice per job — re-invoicing creates a new invoice after voiding)

### 2.3 Customer (Aggregate Root) — Customer Context

**Root Entity: Customer**
| Field | Type | Notes |
|---|---|---|
| id | CustomerId (UUID) | |
| businessId | BusinessId | Tenant isolation |
| name | PersonName (VO) | |
| contactMethods | ContactMethod[] | Phone, email, etc. |
| serviceLocations | ServiceLocation[] | Where work is performed |
| tags | string[] | Free-form labels ("VIP", "slow payer") |
| createdAt | Timestamp | |

**Child Entity: ServiceLocation**
| Field | Type | Notes |
|---|---|---|
| id | ServiceLocationId (UUID) | |
| label | string | "Home", "Office", "Rental on Oak St" |
| address | Address (VO) | Full postal address |
| accessNotes | string? | "Gate code 4521", "Dog in backyard" |

**Invariants:**
1. A Customer must have at least one ContactMethod
2. A Customer must have at least one ServiceLocation (created with first job if needed)
3. Customer name cannot be blank

### 2.4 Business (Aggregate Root) — Identity Context

**Root Entity: Business**
| Field | Type | Notes |
|---|---|---|
| id | BusinessId (UUID) | |
| name | string | Business name |
| tradeType | TradeType (VO) | Plumbing, Electrical, Cleaning, Landscaping, General |
| contactEmail | EmailAddress (VO) | |
| contactPhone | PhoneNumber (VO) | |
| address | Address (VO) | Business address (for invoice headers) |
| logoStorageKey | string? | Uploaded logo for quotes/invoices |

**Invariants:**
1. Business name cannot be blank
2. Must have at least contactEmail or contactPhone

### 2.5 User (Aggregate Root) — Identity Context

**Root Entity: User**
| Field | Type | Notes |
|---|---|---|
| id | UserId (UUID) | |
| businessId | BusinessId | Which business they belong to |
| email | EmailAddress (VO) | Login identity |
| name | PersonName (VO) | |
| role | UserRole | Owner or TeamMember |
| passwordHash | string | |

**Invariants:**
1. Email is unique across the system
2. Each Business must have exactly one Owner
3. A User belongs to exactly one Business

---

## 3. Value Objects

### Money
| Property | Type | Validation |
|---|---|---|
| amount | integer | Stored in cents. Non-negative for prices. Can be negative for adjustments/credits. |
| currency | string | ISO 4217. Default "USD". Always 3 uppercase letters. |

Behavior: add, subtract, multiply by quantity. Never use floating point.

### LineItem
| Property | Type | Validation |
|---|---|---|
| description | string | Non-blank, max 200 chars |
| quantity | number | Positive, up to 2 decimal places (e.g., 2.5 hours) |
| unitPrice | Money | Non-negative |
| total | Money | Computed: quantity * unitPrice |

### ScheduleSlot
| Property | Type | Validation |
|---|---|---|
| date | LocalDate | Cannot be in the past at creation time |
| startTime | LocalTime? | Optional — many trades just book a day, not an hour |
| endTime | LocalTime? | Must be after startTime if both present |
| notes | string? | "Morning preferred", "After school pickup" |

Design decision: ScheduleSlot is a value object, not an entity, because there is no
concept of schedule conflict enforcement for solo operators. A tradesperson who books
two jobs on Tuesday is making a conscious choice, not a mistake. The calendar view
shows overlaps — the system does not prevent them. This avoids complex scheduling
logic that doesn't match how trades actually work.

### Address
| Property | Type | Validation |
|---|---|---|
| street | string | Non-blank |
| street2 | string? | Apartment, suite, etc. |
| city | string | Non-blank |
| state | string | Non-blank |
| postalCode | string | Non-blank |
| country | string | ISO 3166-1 alpha-2, default "US" |

### PersonName
| Property | Type | Validation |
|---|---|---|
| firstName | string | Non-blank |
| lastName | string | Non-blank |

Provides: fullName() -> "firstName lastName"

### EmailAddress
| Property | Type | Validation |
|---|---|---|
| value | string | Must match basic email regex. Stored lowercase. |

### PhoneNumber
| Property | Type | Validation |
|---|---|---|
| value | string | Stored as digits only. Must be 10-15 digits. |
| formatted | string | Computed: "(555) 123-4567" format for US |

### ContactMethod
| Property | Type | Validation |
|---|---|---|
| type | enum | Phone, Email, Text |
| value | string | Valid phone or email depending on type |
| isPrimary | boolean | At most one per type |

### InvoiceNumber
| Property | Type | Validation |
|---|---|---|
| value | string | Format: "INV-{sequential number}". Unique per business. |

### Material
| Property | Type | Validation |
|---|---|---|
| name | string | Non-blank ("1/2 inch copper elbow") |
| quantity | number | Positive |
| unitCost | Money | What the tradesperson paid |
| isChargeable | boolean | Whether to pass cost to customer |

### Quantity
| Property | Type | Validation |
|---|---|---|
| value | number | Positive, up to 2 decimal places |

### TradeType
Enum: Plumbing, Electrical, HVAC, Cleaning, Landscaping, Painting, Handyman, General

---

## 4. Domain Events

### Job Management Context

**InquiryReceived**
- When: A new job is created from a customer inquiry
- Data: { jobId, businessId, customerId, locationId, title, description, receivedAt }
- Triggers: Customer context updates last-contact timestamp

**QuoteAttached**
- When: A quote is added to a job
- Data: { jobId, quoteId, lineItems[], totalAmount }
- Triggers: Nothing directly — quote is still a draft

**QuoteSent**
- When: A quote is delivered to the customer
- Data: { jobId, quoteId, customerId, sentAt, sentVia (email/text) }
- Triggers: Notification context sends the quote document

**QuoteAccepted**
- When: Customer accepts a quote
- Data: { jobId, quoteId, acceptedAt, totalAmount }
- Triggers: Job may auto-advance to Scheduled if schedule slot exists

**QuoteRejected**
- When: Customer rejects a quote
- Data: { jobId, quoteId, rejectedAt, reason? }
- Triggers: Job moves to Lost (unless requoted)

**JobScheduled**
- When: A schedule slot is assigned and job moves to Scheduled
- Data: { jobId, scheduleSlot, customerId }
- Triggers: Nothing — scheduling is internal

**JobStarted**
- When: Work begins on a job
- Data: { jobId, startedAt }
- Triggers: Nothing

**JobCompleted**
- When: All work is finished on a job
- Data: { jobId, businessId, customerId, completedAt, quote?, materials[], notes[] }
- Triggers: Billing context creates a draft Invoice seeded from job data

**JobLost**
- When: A job is abandoned (quote rejected, customer unresponsive, etc.)
- Data: { jobId, lostAt, reason? }
- Triggers: Customer context records the lost job

### Billing Context

**InvoiceCreated**
- When: A draft invoice is generated (usually from JobCompleted)
- Data: { invoiceId, jobId, businessId, customerId, lineItems[], totalAmount }
- Triggers: Nothing — it's a draft awaiting review

**InvoiceSent**
- When: Invoice is delivered to customer
- Data: { invoiceId, customerId, sentAt, sentVia, dueDate }
- Triggers: Notification context sends the invoice document

**PaymentRecorded**
- When: Any payment is applied to an invoice
- Data: { invoiceId, paymentId, amount, method, receivedAt, outstandingBalance }
- Triggers: If outstandingBalance is zero, triggers InvoicePaid

**InvoicePaid**
- When: All money owed on an invoice has been received
- Data: { invoiceId, jobId, totalAmount, paidAt }
- Triggers: Customer context updates lifetime value

**InvoiceOverdue**
- When: System detects an unpaid invoice past its due date
- Data: { invoiceId, customerId, dueDate, outstandingBalance, daysOverdue }
- Triggers: Notification context sends a follow-up reminder

**InvoiceVoided**
- When: An invoice is cancelled
- Data: { invoiceId, voidedAt, reason? }
- Triggers: Nothing

### Customer Context

**CustomerCreated**
- When: A new customer is added to the system
- Data: { customerId, businessId, name, contactMethods[], serviceLocations[] }
- Triggers: Nothing

**ServiceLocationAdded**
- When: A new location is added to an existing customer
- Data: { customerId, locationId, address, label }
- Triggers: Nothing

---

## 5. Anti-Corruption Layers

### Email ACL (Notification Context -> Email Provider)

The Notification context speaks in terms of Messages and Recipients. The Email ACL
translates to provider-specific API calls.

**Domain-side interface:**
```
EmailGateway {
  send(recipient: Recipient, subject: string, htmlBody: string, attachments?: Attachment[]): DeliveryResult
}
```

**Translation layer:**
- Recipient -> provider's "to" field format
- htmlBody -> provider's content format (some require multipart)
- Attachment -> provider's attachment encoding (base64, etc.)
- Provider error codes -> DeliveryResult (Delivered, Failed, Bounced)

**Adapters:**
- DTU twin: `DtuEmailGateway` — stores sent emails in database, always returns Delivered
- Production: `ResendEmailGateway` or `PostmarkEmailGateway` — real delivery

### Payment Processing ACL (Billing Context -> Payment Provider)

For MVP, payments are manually recorded (cash, check, Venmo). The ACL exists as a
seam for future online payment integration.

**Domain-side interface:**
```
PaymentGateway {
  createPaymentLink(invoice: InvoiceSnapshot, customer: CustomerSnapshot): PaymentLink
  verifyPayment(externalPaymentId: string): PaymentVerification
}
```

**Translation layer:**
- InvoiceSnapshot -> provider's "checkout session" or "payment intent"
- Provider webhook events -> PaymentVerification value object
- Provider error states -> domain-meaningful failures

**Adapters:**
- DTU twin: `DtuPaymentGateway` — generates fake payment links, simulates payment after delay
- Production: `StripePaymentGateway` — real Stripe Checkout

### File Storage ACL (Job Management Context -> Object Storage)

Photos need external storage. The domain speaks in terms of Photos with storage keys.

**Domain-side interface:**
```
FileStore {
  upload(file: Buffer, contentType: string): StorageKey
  getUrl(key: StorageKey): string
  delete(key: StorageKey): void
}
```

**Adapters:**
- DTU twin: `DtuFileStore` — stores files on local filesystem, serves via static route
- Production: `RailwayBlobStore` — Railway's built-in blob storage

---

## 6. DTU Twins

### DtuEmailService

**Simulates:** Transactional email provider (Resend, Postmark, SendGrid)

**Behavior:**
- Accepts send requests with recipient, subject, body, attachments
- Stores all sent emails in a database table (`dtu_sent_emails`)
- Always returns success (simulates reliable delivery)
- Provides a `/dtu/emails` debug UI to view all sent emails during development
- Simulates webhook callbacks for delivery status after 2-second delay

**Why needed:** Quote and invoice delivery are core workflows. Without a DTU twin,
you can't develop or test the full job lifecycle end-to-end.

### DtuPaymentService

**Simulates:** Payment processor (Stripe)

**Behavior:**
- Generates fake payment links that resolve to a DTU-hosted payment page
- The DTU payment page has a "Simulate Payment" button
- On simulated payment, fires a webhook back to the app with payment confirmation
- Supports simulation of: successful payment, declined card, partial payment
- Stores all transactions in `dtu_payment_transactions` table

**Why needed:** The paid state is the terminal state of the entire lifecycle. Without
simulating payments, you can't test the complete flow or develop the payment tracking UI.

### DtuFileStorage

**Simulates:** Object storage (Railway Blob Storage)

**Behavior:**
- Stores uploaded files on local disk in a `./uploads` directory
- Serves files via a static file route (`/uploads/:key`)
- Generates storage keys as UUID-based paths
- Supports basic operations: upload, get URL, delete

**Why needed:** Job documentation with photos is a core workflow. Local file storage
is sufficient for development and small-scale self-hosted deployments.

---

## 7. Tech Stack

### Language: TypeScript

**Justification:** The target audience (and contributors to an open-source project)
favors a language with a large ecosystem and low barrier to entry. TypeScript gives
us strong typing for domain model correctness, good IDE support, and a single
language across the stack. The DDD community has mature TypeScript patterns
(see Khalil Stemmler's work, or the Node DDD sample projects).

### Runtime: Node.js (LTS)

### Framework: Fastify

**Justification:** Express is ubiquitous but aging. Fastify is faster, has better
TypeScript support, built-in schema validation with JSON Schema, a clean plugin
architecture that maps well to bounded contexts, and sensible defaults. It's mature
enough for production while being modern enough to not fight against.

### Database: PostgreSQL (single instance)

**Justification:** For a self-hosted app serving solo operators and micro-teams, a
single Postgres instance is the right call. It handles relational data well, supports
JSONB for semi-structured data (job notes, line items), and has excellent tooling.
No need for event sourcing or CQRS at this scale — the domain events are published
in-process and persisted in an events table for auditability, but the primary storage
is traditional relational tables.

Each bounded context gets its own schema (namespace) within the database:
- `job_management.*`
- `billing.*`
- `customer.*`
- `identity.*`
- `notification.*`

This gives logical separation without operational complexity of multiple databases.

### ORM: Drizzle ORM

**Justification:** Lightweight, TypeScript-native, SQL-first. Unlike Prisma, it
doesn't generate a client or require a separate schema file — the schema IS
TypeScript. This aligns with DDD: the domain model is in code, and the persistence
schema maps to it explicitly. No magic, no hidden queries.

### Migrations: Drizzle Kit

### Validation: Zod

**Justification:** Used at the application layer boundary (API input validation).
The domain layer uses its own validation in value object constructors. Zod handles
the "is this valid HTTP input?" question; the domain handles "is this valid business
data?" question.

### Frontend: HTMX + server-rendered templates (Handlebars)

**Justification:** TradeFlow's UI is form-driven and action-oriented. There's no
complex client-side state management. A tradesperson on a job site needs pages
that load fast on spotty cellular, forms that submit reliably, and zero JavaScript
bundle to download. HTMX gives us dynamic UI updates (inline editing, live search,
status changes) without an SPA framework. Handlebars provides clean server-side
templating. This is a deliberate choice against React/Vue/Svelte — the complexity
budget belongs in the domain model, not the UI framework.

### CSS: Tailwind CSS

**Justification:** Utility-first CSS that works well with server-rendered HTML.
Fast to build with, easy to maintain, and produces small CSS bundles. No component
library — we build what we need.

### Authentication: Lucia (session-based)

**Justification:** Lucia is a lightweight, framework-agnostic auth library for
session-based authentication. It works with any database (we use Postgres). For
self-hosted software used by micro-teams, session-based auth with email/password
is the right default. OAuth can be added later as an enhancement.

### Testing: Vitest

**Justification:** Fast, TypeScript-native, compatible with the Node ecosystem.
Domain model tests are pure unit tests (no mocks needed — the domain has no
dependencies). Integration tests use a test database.

### Process: Single process, in-process event bus

**Justification:** At the scale of a solo operator's business, there is zero reason
for message queues, separate microservices, or distributed events. Domain events
are dispatched synchronously within the request lifecycle or via a simple in-process
event emitter for eventual consistency (e.g., sending notifications). If the app
ever needs to scale, the bounded contexts are already separated — extracting a
service is a deployment change, not a domain change.

---

## 8. Project Structure

```
src/
├── shared/                          # Shared kernel — used by all contexts
│   ├── domain/
│   │   ├── Entity.ts                # Base entity class with ID
│   │   ├── AggregateRoot.ts         # Base aggregate with domain event collection
│   │   ├── ValueObject.ts           # Base value object with equality
│   │   ├── DomainEvent.ts           # Base domain event interface
│   │   ├── Money.ts                 # Money value object
│   │   ├── Address.ts               # Address value object
│   │   ├── EmailAddress.ts          # Email value object
│   │   ├── PhoneNumber.ts           # Phone value object
│   │   ├── PersonName.ts            # Name value object
│   │   └── types.ts                 # Branded types (BusinessId, UserId, etc.)
│   ├── infrastructure/
│   │   ├── EventBus.ts              # In-process domain event dispatcher
│   │   ├── db.ts                    # Database connection (shared Postgres pool)
│   │   └── UnitOfWork.ts            # Transaction management
│   └── application/
│       └── middleware/               # Auth, error handling, tenant resolution
│
├── job-management/                   # Core domain context
│   ├── domain/
│   │   ├── Job.ts                   # Job aggregate root
│   │   ├── Quote.ts                 # Quote entity (child of Job)
│   │   ├── JobNote.ts               # Note entity
│   │   ├── Photo.ts                 # Photo entity
│   │   ├── LineItem.ts              # Line item value object
│   │   ├── Material.ts             # Material value object
│   │   ├── ScheduleSlot.ts          # Schedule slot value object
│   │   ├── JobStatus.ts             # Status enum and transition rules
│   │   ├── QuoteStatus.ts           # Quote status enum
│   │   └── events/                  # Domain events
│   │       ├── InquiryReceived.ts
│   │       ├── QuoteAttached.ts
│   │       ├── QuoteSent.ts
│   │       ├── QuoteAccepted.ts
│   │       ├── QuoteRejected.ts
│   │       ├── JobScheduled.ts
│   │       ├── JobStarted.ts
│   │       ├── JobCompleted.ts
│   │       └── JobLost.ts
│   ├── application/
│   │   ├── commands/                # Use cases that change state
│   │   │   ├── CreateJob.ts
│   │   │   ├── AttachQuote.ts
│   │   │   ├── SendQuote.ts
│   │   │   ├── AcceptQuote.ts
│   │   │   ├── ScheduleJob.ts
│   │   │   ├── StartJob.ts
│   │   │   ├── CompleteJob.ts
│   │   │   ├── AddJobNote.ts
│   │   │   ├── AddPhoto.ts
│   │   │   └── RecordMaterial.ts
│   │   └── queries/                 # Read-side use cases
│   │       ├── GetJob.ts
│   │       ├── ListJobs.ts
│   │       ├── GetJobsByStatus.ts
│   │       ├── GetSchedule.ts
│   │       └── SearchJobs.ts
│   ├── infrastructure/
│   │   ├── persistence/
│   │   │   ├── schema.ts           # Drizzle schema for job_management.*
│   │   │   ├── JobRepository.ts     # Persistence implementation
│   │   │   └── mappers.ts          # Domain <-> persistence mapping
│   │   └── file-storage/
│   │       ├── FileStore.ts         # Port interface
│   │       ├── DtuFileStore.ts      # DTU twin
│   │       └── S3FileStore.ts       # Production adapter (future)
│   └── interface/
│       ├── routes.ts                # Fastify route registration
│       ├── handlers/                # HTTP handlers (thin — delegate to commands)
│       └── templates/               # Handlebars templates for job views
│
├── billing/                          # Supporting domain context
│   ├── domain/
│   │   ├── Invoice.ts               # Invoice aggregate root
│   │   ├── InvoiceLine.ts           # Invoice line entity
│   │   ├── Payment.ts               # Payment entity
│   │   ├── InvoiceNumber.ts         # Invoice number value object
│   │   ├── InvoiceStatus.ts         # Status enum and transition rules
│   │   ├── PaymentMethod.ts         # Payment method enum
│   │   └── events/
│   │       ├── InvoiceCreated.ts
│   │       ├── InvoiceSent.ts
│   │       ├── PaymentRecorded.ts
│   │       ├── InvoicePaid.ts
│   │       ├── InvoiceOverdue.ts
│   │       └── InvoiceVoided.ts
│   ├── application/
│   │   ├── commands/
│   │   │   ├── CreateInvoiceFromJob.ts
│   │   │   ├── SendInvoice.ts
│   │   │   ├── RecordPayment.ts
│   │   │   ├── VoidInvoice.ts
│   │   │   └── CheckOverdueInvoices.ts  # Scheduled job
│   │   ├── queries/
│   │   │   ├── GetInvoice.ts
│   │   │   ├── ListInvoices.ts
│   │   │   └── GetOutstandingBalance.ts
│   │   └── event-handlers/
│   │       └── OnJobCompleted.ts    # Creates draft invoice
│   ├── infrastructure/
│   │   ├── persistence/
│   │   │   ├── schema.ts
│   │   │   ├── InvoiceRepository.ts
│   │   │   └── mappers.ts
│   │   └── payment-gateway/
│   │       ├── PaymentGateway.ts    # Port interface
│   │       ├── DtuPaymentGateway.ts # DTU twin
│   │       └── StripeGateway.ts     # Production adapter (future)
│   └── interface/
│       ├── routes.ts
│       ├── handlers/
│       └── templates/
│
├── customer/                         # Supporting domain context
│   ├── domain/
│   │   ├── Customer.ts              # Customer aggregate root
│   │   ├── ServiceLocation.ts       # Service location entity
│   │   ├── ContactMethod.ts         # Contact method value object
│   │   └── events/
│   │       ├── CustomerCreated.ts
│   │       └── ServiceLocationAdded.ts
│   ├── application/
│   │   ├── commands/
│   │   │   ├── CreateCustomer.ts
│   │   │   ├── UpdateCustomer.ts
│   │   │   └── AddServiceLocation.ts
│   │   ├── queries/
│   │   │   ├── GetCustomer.ts
│   │   │   ├── ListCustomers.ts
│   │   │   ├── SearchCustomers.ts
│   │   │   └── GetCustomerHistory.ts
│   │   └── event-handlers/
│   │       ├── OnJobCompleted.ts    # Updates customer job history
│   │       └── OnInvoicePaid.ts     # Updates lifetime value
│   ├── infrastructure/
│   │   └── persistence/
│   │       ├── schema.ts
│   │       ├── CustomerRepository.ts
│   │       └── mappers.ts
│   └── interface/
│       ├── routes.ts
│       ├── handlers/
│       └── templates/
│
├── notification/                     # Generic subdomain
│   ├── domain/
│   │   ├── Message.ts
│   │   ├── Recipient.ts
│   │   ├── DeliveryAttempt.ts
│   │   └── DeliveryStatus.ts
│   ├── application/
│   │   ├── commands/
│   │   │   └── SendMessage.ts
│   │   └── event-handlers/
│   │       ├── OnQuoteSent.ts       # Sends quote email
│   │       ├── OnInvoiceSent.ts     # Sends invoice email
│   │       └── OnInvoiceOverdue.ts  # Sends follow-up reminder
│   ├── infrastructure/
│   │   └── email/
│   │       ├── EmailGateway.ts      # Port interface
│   │       ├── DtuEmailGateway.ts   # DTU twin
│   │       └── ResendGateway.ts     # Production adapter (future)
│   └── interface/
│       └── dtu-debug/               # Dev-only UI to inspect sent emails
│
├── identity/                         # Generic subdomain
│   ├── domain/
│   │   ├── User.ts
│   │   ├── Business.ts
│   │   └── UserRole.ts
│   ├── application/
│   │   ├── commands/
│   │   │   ├── RegisterBusiness.ts   # Creates business + owner user
│   │   │   ├── InviteTeamMember.ts
│   │   │   └── Login.ts
│   │   └── queries/
│   │       └── GetCurrentUser.ts
│   ├── infrastructure/
│   │   ├── persistence/
│   │   │   └── schema.ts
│   │   └── auth/
│   │       └── lucia.ts             # Lucia auth configuration
│   └── interface/
│       ├── routes.ts
│       ├── handlers/
│       └── templates/               # Login, register pages
│
├── dtu/                              # DTU twin services (dev only)
│   ├── email/
│   │   ├── server.ts                # In-app DTU email service
│   │   └── ui/                      # Debug inbox viewer
│   └── payments/
│       ├── server.ts                # In-app DTU payment service
│       └── ui/                      # Simulate payment page
│
├── app.ts                            # Fastify app setup, plugin registration
├── server.ts                         # Entry point, reads $PORT
└── event-wiring.ts                   # Connects domain events to handlers across contexts

templates/                            # Shared Handlebars layouts
├── layouts/
│   ├── main.hbs                     # Primary app layout
│   └── public.hbs                   # Landing/auth pages layout
├── partials/
│   ├── nav.hbs
│   ├── job-card.hbs
│   ├── status-badge.hbs
│   └── line-item-row.hbs
└── pages/
    ├── landing.hbs                  # Marketing/about page
    └── dashboard.hbs                # Main dashboard

public/                               # Static assets
├── css/
│   └── app.css                      # Tailwind output
├── js/
│   └── htmx.min.js                  # HTMX library
└── img/

drizzle/                              # Database migrations
├── 0000_initial.sql
└── meta/

Dockerfile
railway.json
package.json
tsconfig.json
vitest.config.ts
tailwind.config.ts
```

---

## Design Decisions Log

### Why Quote is embedded in Job, not a separate aggregate

The strongest argument for separating them: "A quote can be revised multiple times
before acceptance." But revising a quote is revising *the quote on this job*. There's
no scenario in this domain where a quote floats free, unattached to work. The quote
needs access to the job's location, customer, and description to make sense. Embedding
it preserves the consistency boundary (you can't accept a quote while the job is being
modified) and simplifies the model.

If we later discover that quotes need independent versioning or approval workflows,
we extract. But for solo operators quoting from a truck, embedded is correct.

### Why Invoice is NOT embedded in Job

The opposite argument applies. Once work is done, the financial lifecycle is
genuinely independent. An invoice can be voided and reissued without touching the
job. Payment tracking has its own invariants (payments can't exceed total, partial
payments are tracked). The language shifts from "work" to "money." And critically:
a business owner looking at their invoices does not want to navigate through jobs
to find them. Invoices are a first-class concept in the Billing context.

### Why no CQRS or Event Sourcing

At the scale of a solo plumber's business (maybe 500 jobs/year, 500 invoices/year),
event sourcing adds complexity with no benefit. The domain events are published and
persisted in an events table for auditability and cross-context communication, but
the source of truth is the aggregate's current state in relational tables. If we
needed temporal queries ("what was the quote at the time of acceptance?"), we'd
add event sourcing to that specific aggregate. We don't need it yet.

### Why schedule conflicts are not enforced

A plumber who books two jobs on Tuesday morning is not making an error — they might
be planning to send a helper to one, or they know the first job will be quick. The
system shows overlaps visually but does not prevent them. For micro-teams with 1-5
people, schedule conflicts are a human judgment call, not a system invariant.

### Why single database with schemas instead of database-per-context

Operational simplicity. A self-hosted app on Railway should not require managing
multiple database instances. Schema-level separation gives us the logical boundary
between contexts (each context only queries its own schema) while keeping deployment
simple. If a context needs to reference another, it does so through published events
or a read model, never by joining across schemas.

### Why HTMX instead of a JavaScript SPA

The domain complexity is server-side. The UI needs are: forms, lists, status updates,
and a calendar view. A React SPA would add 200KB+ of JavaScript, a build pipeline,
client-side state management, and API serialization — all to render forms. HTMX gives
us dynamic behavior (inline editing, partial page updates, real-time status changes)
with <15KB of JavaScript and zero client-side state. The complexity budget goes to
the domain model, not the UI framework.
