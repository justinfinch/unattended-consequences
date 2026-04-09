# Human Tasks

Tasks that require human action. Claude will add items here as they're
discovered during development. Work through these at your own pace.

## Infrastructure Setup

- [ ] **Create Railway project and service** — In the Railway dashboard
  (https://railway.app), create a new project for TradeFlow:
  1. Create a new project
  2. Add a new service linked to this repo
  3. Set the deploy branch to `product-alpha`
  4. Railway auto-sets `$PORT` — no manual config needed for that
  5. Note the generated URL for testing

- [ ] **Provision Railway PostgreSQL database** — In the same Railway project:
  1. Click "New" → "Database" → "PostgreSQL"
  2. Railway auto-injects `DATABASE_URL` into the service environment
  3. No manual connection string configuration needed
  4. Verify the database addon appears linked to your service

## Environment Variables

- [ ] **Set required environment variables** in Railway service settings:
  | Variable | Value | Notes |
  |---|---|---|
  | `NODE_ENV` | `production` | Enables production mode |
  | `SESSION_SECRET` | (generate a random 64-char string) | For Lucia session encryption |
  | `DTU_MODE` | `false` | Set to `true` only for development |

  Railway auto-provides: `PORT`, `DATABASE_URL`

## Domain & DNS (Optional)

- [ ] **Custom domain setup** (optional, only if desired):
  1. In Railway service settings, go to "Settings" → "Networking"
  2. Add your custom domain (e.g., `tradeflow.yourdomain.com`)
  3. Add the CNAME record Railway provides to your DNS
  4. Wait for SSL certificate provisioning (automatic)

## Future: External Service Integration

These tasks become relevant when moving from DTU twins to real services:

- [ ] **Email provider setup** (Resend recommended):
  1. Create account at https://resend.com
  2. Verify a sending domain
  3. Generate an API key
  4. Set `RESEND_API_KEY` environment variable in Railway
  5. Set `DTU_MODE=false` or `EMAIL_PROVIDER=resend` in Railway

- [ ] **Stripe payment integration** (when ready for online payments):
  1. Create Stripe account at https://stripe.com
  2. Get API keys from Dashboard → Developers → API keys
  3. Set `STRIPE_SECRET_KEY` and `STRIPE_PUBLISHABLE_KEY` in Railway
  4. Configure webhook endpoint: `https://your-app.railway.app/billing/webhooks/stripe`
  5. Set `STRIPE_WEBHOOK_SECRET` from the webhook configuration

- [ ] **File storage** (when scaling beyond local storage):
  1. In your Railway project, click "New" → "Database" → "Blob Storage"
  2. Railway auto-injects blob storage credentials into the service environment
  3. No manual credential configuration needed
