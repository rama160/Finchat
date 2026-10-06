## Subscription baseline +18

Lihat ../../docs/playstore/SUBSCRIPTION.md. Enam produk monthly/yearly; katalog generated dari JSON, FREE5AI/10Voice/5Scan, Plus50/100/100, Pro200/500/500, Max500/1500/1500. Endpoint /v1/quota/state,reserve,settle,event memakai ledger perGoogleaccount; AIclient tidak dapatreserve/refund langsung. Reinstall/backup bukanreset. Existingdeploypilot tidak diubah. Gemini unpaid menerima hanya enumtopic tanpa personaldata jika UNPAID_EDUCATION_ENABLED=true; personalAI tetap requiresPAID_AI_CONFIRMED=true explicit. Tidak adaupgradeinfrastructureotomatis. Catatan lama di bawah mempertahankan historibuild+17.

# Spenva Play billing server (prepared, not deployed)

Worker independent of the pilot finchat-ai-gateway. Node24 `node --test worker.test.mjs` runs mocked upstream security/quota tests. It is not evidence of a completed real purchase or billed Google API configuration.

## Required configuration

- New Cloudflare Worker `spenva-play-billing`, new SQLite Durable Object QUOTA, new FEEDBACK KV namespace. Replace the KV placeholder. Never reuse pilot gateway usage/feedback bindings.
- GOOGLE_CLIENT_ID: the application's existing **web** OAuth client ID. Server verifies Google JWT RS256 signature, issuer, audience, expiry and issued-at; SHA256(sub) binds entitlement to Play obfuscatedExternalAccountId.
- Secrets: PLAY_SERVICE_ACCOUNT_EMAIL, PLAY_SERVICE_ACCOUNT_PRIVATE_KEY (PKCS8 PEM), GEMINI_API_KEY (billed project), ADMIN_TOKEN (strong randomly generated secret). Do not commit/export any secret.
- Enable Android Publisher API in the correct Google project; grant the service account required app subscription access in Play Console. Confirm3 products finchat_basic_monthly/pro/unlimited with base plan monthly and auto-renewing one month.
- Activate a Google Cloud billed project through the owner's account and review Gemini Paid Services terms. Set PAID_AI_CONFIRMED=true only after confirmation. Default false rejects AI. No free/pilot or more-expensive model fallback. Verify model availability before deployment and budget alerts/limits.
- Worker logging is disabled by default. Do not enable request-header/body logging; these contain Google identity, purchase tokens and financial context.

## Routes

POST /v1/purchases/verify: Bearer Google ID token + JSON purchaseToken. Independently reads Google subscriptionsv2 for fixed package com.finchat.finchat, matching account/product/monthly base plan/future expiry/active state. Allows grace and canceled-until-expiry; rejects pending/expired/paused/on-hold. Acknowledges valid pending-ack purchases server-side. Never grant access from client status.

POST /v1/ai/chat: same identity + X-Play-Purchase-Token; verifies subscription again on **every call**. One user message, max20KB body and10K characters; model countTokens enforces4096 input and768 output. Atomic DO quota100/300/1000 per expiry cycle; max10/minute; failed model calls refund reservation. No prompt/answer persistence here.

POST /v1/feedback: same identity, reason1–500 chars; optionalquestion5000/answer10000 chars included only after user's explicit choice. Stored30days in FEEDBACK. Do not claim success unless201. GET /v1/admin/reports accepts ADMIN_TOKEN and paginates50 reports with optionalcursor; operator must review reports regularly and remove dangerous output patterns/prompts, not merely collect complaints. This is a real operational responsibility before AI launch.

POST /v1/delete-self: same Google identity, deletes matching report records. Retains only pseudonymous quota counters through end of paid period+30days to prevent delete-reset abuse; alarms purge old cycles. Google owns payment records. This endpoint cannot erase a user's Drive without permission or cancel subscriptions.

GET /health: service/version only; no secrets.

## Production verification before SPENVA_BILLING_ENDPOINT is set

Deploy only after real bindings/secrets/products are available. Test via Play internal testing license accounts: purchasepending, successful purchase+ack≤3days, restore/reinstall, account mismatch, revoked/refunded, expiration, grace, cancellation and loss of internet. Tokens must be obfuscated-bound on purchase. Confirm Play price matches monthly plan, check Publisher API quota, latency and errors. Only Google Play may take payment; no external checkout URLs.

Verify atomic parallel quota calls on deployed DO, failures returning quota and alarm expiry. Test report listing/deletion and external support request procedure. KV is eventually consistent: retry deletion and confirm after propagation before promising deletion completion to external requests. Service failure never unlocks paid features. No RTDN is configured; real-time entitlement is checked on demand. Server tests mock Google; real APIs are a publication gate. A new purchase from a second device while an existing different plan is active is a limitation of the current UI-only duplicate prevention: do not promote in-place upgrades; inspect subscriptions before account support/change requests.

Publisher handling external deletion: verify request ownership without asking for Google password/payment details; use the in-app Google-authenticated deletion path for linked server reports when available or resolve hashed subject from verified account evidence. Remove server reports; explain minimal billing retention. Guide user through Drive Settings → Manage apps → Spenva/FinChat → delete hidden app data and Google Play cancellation, without requiring reinstall. Local-only data cannot be remotely deleted; requesters can remove it through Android app storage, with explicit notice of irreversible loss. Never ask users to email their financial database.
