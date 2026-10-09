> Current source status: **0.3.4+19**, 9 October 2026 UTC. See [../SPENVA_CANONICAL_SOURCE.md](../SPENVA_CANONICAL_SOURCE.md) and the current detailed audit. Older version/build statements below are historical evidence and do not verify this patch.

# Data safety and review access — preparation matrix

This is an implementation-informed draft, not a completed Console declaration. The publisher must reconcile it with current Google SDK disclosures, backend hosting/logging, voice recognizer providers and actual release configuration. Data sent off-device can be collected even if ephemeral. Do not tick “no data collected” simply because the primary database is local.

| Data / path | Where and when | Purpose / declaration review |
| --- | --- | --- |
| Email, name, Google user identifier | Google sign-in + local profile; ID token reaches subscription/quota server after user selects relevant feature | Account management/authentication. Google optional; review Name, Email address, User IDs. Local-only offline placeholder does not create a cloud account. |
| Transaction amount/date/category/description, income/balance | Local SQLite; entire DB to chosen Google Drive account only when backup requested/enabled | App functionality/backup; Financial info → Other financial info; descriptions may contain personal info. Backup may include other local profiles on shared device. |
| Questions, summaries and ≤25 transaction snippets | Cloudflare → Gemini **Paid API only**, after authenticated quota/entitlement verification + in-app18+/cloud consent | App functionality; Other financial info and Other in-app messages where applicable. Sent off device, optional, no custom server persistence; review Google retention/security terms. |
| Play purchase token/account hash/expiry/Voice-Scan-AI-PDF usage | Verification server/Google Play; pseudonymous quota in Durable Object | Purchases/payment authorization/security; Purchase history and User IDs; counter end of cycle+30days, no financial prompts. Google maintains its own purchase records. |
| Feedback reason; optionalquestion/answer | FEEDBACK KV after explicit in-app report | Support/content safety;30day retention. Review Other in-app messages/financial info if user deliberately includes them. Operator-only admin endpoint. |
| Voice | Platform speech recognizer on demand | Local/device service may use network; review Audio files/voice according to actual recognizer and SDK disclosures. Do not promise fully offline speech. Spenva does not upload audio to paid AI. |
| Receipt photos | Camera/gallery picker → device ML Kit OCR and temporary plugin paths | Device-only image processing is not collection by the app; photos are not sent to AI. Confirm SDK telemetry and temp-file behavior on release device. |
| PDF/manual export | User chooses local save/share recipient | User-directed export. Recipient/copy controlled by user. Avoid automatic cloud upload. |
| Connection/security metadata | Google/Cloudflare infrastructure | Review SDK provider disclosures and device/other IDs; no analytics/ad SDK added. Avoid invented claims that providers collect nothing. |

TLS in transit. SecureStorage for sessions/purchase token; local financial database **not application-encrypted**. No end-to-end-encryption claim. No data sale or advertising. Whether Google/Cloudflare processing qualifies for the Console service-provider sharing exception depends on actual contracts/use; do not simply mark every service as “shared” or exclude all processing. Review optional/required and ephemeral fields against each active feature. If launching Free before paid server, remove/defer paid-data paths in the form and listing; keep app behavior consistent.

Account deletion: in-app Privasi dan data, external public deletion page with support contact. Google SSO is an app-account creation flow for policy. Logout does not delete records. Deletion clears active profile and learning locally and optionally matching backup data; PDFs/shared copies/other devices require user action. Quota anti-abuse retention must be disclosed. Subscription must be canceled separately in Google Play.

## App access for reviewers

Metered features on Play require a Google account and server connection, including Free Voice/Scan/PDF. Fixed-topic unpaid education does not forward raw questions/history; personal financial AI stays disabled by default. Successful local batches and fallback/error counters are pseudonymous operational events, without transaction content.

Free: open app → Gunakan mode offline → Mulai (no email required), enter “gaji5 juta” then “nasi10 ribu dan bakso5 ribu”, ask total, open Laporan, choose period. PDF requires quota verification/account; Free has one successful export per month. No paid feature needed for these tasks. Use actual spaces in inputs as displayed by examples.

Cloud features: provide precise Google reviewer access/OAuth test-user setup and license-test accounts through **Console restricted review instructions**, not repository/password logs. Reviewer must have access to AI once enabled without real charge. Explain restore and flag-answer path. Do not give a shared personal Google password; resolve Google's app-access requirements via permitted review/test setup. If OAuth app still test-only, publish/verify OAuth and its requested scopes or add permitted reviewers before submitting.

Complete content rating/target audience honestly. AI service terms require18+ and not targeting minors; in-app age affirmation exists but Console audience/rating must also fit. Financial features declaration describes budgeting/personal expense tracking, no loans, banking/trading, financial transfer or payment service.

Sources: https://support.google.com/googleplay/android-developer/answer/10787469 ; https://support.google.com/googleplay/android-developer/answer/13327111 ; https://ai.google.dev/gemini-api/terms
