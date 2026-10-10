# Spenva subscription dan quota server

**Versi sumber: 0.3.5+20**


Separate Worker from the existing finchat-ai-gateway. Prepared source, not deployed. Run Node24 `node --test` or `npm test` for all backend tests. Upstream tests are simulations, not evidence of real Play purchases. Catalog, prices, quotas and AI level are generated from assets/config/subscription_plans.json; regenerate with tooling/play/generate_subscription.py, and validate with --check.

## Configuration

Create a new spenva-play-billing Worker, SQLite Durable Object QUOTA and FEEDBACK KV. Replace the namespace placeholder in wrangler.jsonc. Do not reuse pilot bindings or change the existing gateway. GOOGLE_CLIENT_ID keeps the application's existing web OAuth client ID. Never store keys in the APK/repository/logs.

Google Play requires PLAY_SERVICE_ACCOUNT_EMAIL and PLAY_SERVICE_ACCOUNT_PRIVATE_KEY (PKCS8 PEM), Android Publisher API access and the minimum app subscription permissions. Create six products: finchat_plus_monthly/yearly, finchat_pro_monthly/yearly, finchat_max_monthly/yearly. Each has its matching monthly/yearly base plan, renewing for one month/year. Verify all final prices in Console and the Play purchase sheet. A server-issued entitlement is required; client purchased status cannot unlock a plan.

Set an ADMIN_TOKEN for reports. GEMINI_API_KEY is only required if cloud AI is enabled. PAID_AI_CONFIRMED=false and UNPAID_EDUCATION_ENABLED=false are defaults. No code upgrades infrastructure to paid. Unpaid education accepts only fixed budget/emergency/saving topics and does not forward raw questions or finances. Personal financial AI requires an explicitly configured provider/project that permits this data, consent and18+. Keep it disabled otherwise. Review provider/global limits; consider paid infrastructure only after recurring revenue and monitoring support it, ideally revenue>=5x cloud cost. Worker request-body/header logs remain disabled.

## Routes

- POST /v1/purchases/verify: signed Google ID token and purchaseToken. Independently checks Google subscriptionsv2, fixed package com.finchat.finchat, account hash, six products, base plan, startTime, expiry and state. ACTIVE, CANCELED and GRACE_PERIOD keep paid access until expiry. Expired/on-hold/paused/pending become Free for quota access. Only a valid purchase is acknowledged. The server stores the purchase association to recover after reinstall/device change.
- POST /v1/quota/state,reserve,settle,event: signed Google identity; optional purchase header or server association. Atomic per-account ledger contains separate Voice/Scan/AI/PDF counters, plan and billing period. Free follows UTC calendar months; monthly and yearly paid plans get monthly windows anchored to Google startTime. Switching tiers carries current usage. Settle is idempotent. Client cannot reserve AI directly. Abandoned operations stay counted; logout, local deletion and backups do not reset quota.
- POST /v1/ai/chat: verifies identity/entitlement, reserves AI and returns failed credits. Free may use its allowance without a paid purchase. Personal mode accepts one bounded user prompt; unpaid mode accepts only a fixed topic. 20KB body, 10K text, 4096 input tokens, 768 output tokens; fixed gemini-2.5-flash-lite with no costly fallback. Pro/Max use structured analysis and up to4 global concurrency slots; standard tiers use up to2. This is capacity priority, not a latency guarantee. Monitor usage/attempts by plan, fallback, timeouts, upstream errors and rate limits.
- POST /v1/feedback: reason plus optional question/answer sent only by explicit user choice. KV retention30days, server-derived priority for Pro/Max. GET /v1/admin/reports uses ADMIN_TOKEN, paginates50 records and sorts priority within each page. Operator staffing/review are required; no support SLA is implied.
- POST /v1/delete-self: removes linked feedback. Minimal quota/account association retention ends at billing/counter period+30days, including token-expiry cleanup. Does not delete Drive without authorization or cancel Play billing. Publishers must verify deletion requests without passwords, honor KV propagation, and offer a public deletion/support page.
- GET /v1/admin/usage?account=<SHA256>: ADMIN_TOKEN required. Returns persisted plan/status/period, resource usage, attempt/error/fallback counters and completion percentages; never returns purchase tokens, pending reservation IDs or transaction content. Missing usage is null rather than fabricated zero. Operational percentages exclude lost/offline events.
- GET /health: service/version, no keys.

## Activation evidence

Configure a separate free-plan deployment only after bindings/identity/secrets are available. Set SPENVA_BILLING_ENDPOINT only after deployed tests. Test real Play internal-license purchases, pending/ack, cancel-until-expiry, refund/revocation, grace/expiry, restore/reinstall and account mismatch. Test parallel DO reservations, monthly/yearly boundaries, failure refunds, retention alarms, feedback/operator deletion and native Voice/OCR/PDF gates. No RTDN is configured; access is verified against Google on demand. Changes to another product are offered after the current paid period expires; no prorated upgrade is advertised.

Client Voice/OCR/PDF gates can be bypassed on modified/rooted apps; server AI enforcement is authoritative. Metered production features require a Google account and server connection; text/storage/basic reports stay offline. Counter completion events are best-effort operational monitoring, not audited billing records or a global conversion/churn dashboard. See docs/playstore/SUBSCRIPTION.md and LAUNCH.md for complete limits and activation gates.
