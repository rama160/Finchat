# FinChat AI Contract

## Current patch — 0.3.2+11 (2026-10-05)

Authoritative current audit: `AUDIT_0.3.2+11.md`. Fixes RouterDelegate navigatorKey/system Back, CI FFI factory setup, integrated local/AI questions, money-in-question routing, guarded camera/file pickers, voice cancel callbacks, Google Drive snapshot acknowledgements, bottom navigation reports and shared smart period filter. Transaction cards use gestures only; white rounded composer includes emoji/attachment/camera/mic/send.

SQLite schema and existing workflows unchanged. Source is matched to main commit `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Flutter SDK unavailable locally; CI and real Android device acceptance are required. Baseline CI had 72 passed / 1 failed (global FFI factory test setup); do not describe the baseline result as verification of this patch.


AI is supporting intelligence, not source of truth.

## AI must not
- write the database directly;
- invent amounts, dates, totals, or transactions;
- bypass validation;
- silently replace a confirmed user category;
- overwrite confirmed transactions;
- assume missing data as fact.

## Fallback rule
Local parser runs first. AI is called only when local parsing cannot confidently resolve the input.

## Validation
Application validates type, amount, date, category, confidence, and context before persistence.

## Failure behavior
If AI fails, preserve the original input, allow manual correction, and never lose a transaction.

## Financial answers
Use application-computed facts from local data. AI should explain results, not manufacture financial records.

## Production Gateway
The production mobile app uses the FinChat Cloudflare AI Gateway. The app sends a verifiable Google ID token over HTTPS; the Gateway verifies identity and calls Gemini with a server-side secret. The mobile app never contains the shared Gemini API key.

The normal `OpenAiCompatibleAiProvider()` path does not require the legacy local `ai.enabled` switch. `AiSecureConfigService` remains available for explicit legacy/test configuration so existing tests and configuration contracts remain compatible.

## Network hardening
Gateway requests are HTTPS-only, time-bounded and reject oversized or malformed responses. AI remains read-only with respect to SQLite.
