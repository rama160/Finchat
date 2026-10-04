# FinChat AI Contract

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
