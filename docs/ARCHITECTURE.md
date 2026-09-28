# FinChat Architecture

## Layers
1. Presentation
2. Application
3. Domain
4. Data

Supporting services: OCR, image preprocessing, AI, speech, PDF, backup, sync, update.

OCR rules:
- Receipt OCR is an extraction service, not a transaction source of truth.
- OCR output is raw/untrusted text until application validation and local transaction parsing.
- Image preprocessing must not write transactions or categories.
- The concrete OCR provider is isolated behind a domain contract so ML Kit can be replaced without changing the transaction engine.

## Rules
- Local DB is source of truth.
- Repositories isolate persistence.
- SessionManager is the single owner of auth state.
- AI is behind an application/domain contract.
- OCR output is untrusted until validated.
- Sync uses soft delete and conflict detection.
- Schema changes require migration.

## Android OCR release packaging\n\nFinChat currently uses ML Kit Latin text recognition for Indonesian receipt OCR. The CI-generated Android project installs targeted R8 `-dontwarn` rules for optional Chinese, Devanagari, Japanese and Korean ML Kit classes that the plugin references but does not bundle by default. If a non-Latin OCR script is enabled later, the matching official ML Kit language dependency must be added instead of relying on `-dontwarn`.\n\n## Transaction UI integration

The Phase 11 transaction entry path is implemented as:

`ChatScreen composer -> TransactionIntelligenceService -> LocalTransactionParser -> CategoryLearningService -> optional AI fallback -> editable review draft -> SqliteTransactionRepository -> SQLite`

The UI never writes to SQLite through AI. The user reviews the parsed result before persistence, and category corrections are recorded through the learning service.

## Transaction pipeline
Input → normalize → local parser → category engine → validation → AI fallback → validation → review → repository → local DB.

## CI architecture
GitHub Actions is the canonical verification environment. Test workflow runs analyze/test. Android build workflow generates missing Android platform scaffolding on the runner and then builds release APK. This keeps local Flutter installation optional.

## Session persistence

`SessionManager` owns authentication state. `SecureSessionRepository` persists the current session in platform secure storage. Presentation code does not access secure storage directly.

## Update architecture

Presentation → `UpdateService` → `UpdateProvider` → `GitHubReleaseUpdateProvider` → GitHub Releases API.

The provider only reports a newer release and its release URL/APK asset. It does not silently install an APK. Release installation/distribution remains a separate production-hardening concern.

## Documentation architecture

`docs/ROADMAP_AUDIT.md` is the source for known gaps between technical phase baselines and full PRD acceptance. Every future phase must reconcile implementation status and changelog with the actual repository state.


## Phase 12 hardening architecture
Transaction persistence now supports atomic multi-save and pre-persistence validation. Backup snapshots are validated before restore. AI network access is bounded by HTTPS configuration, timeout and response-size checks.

## Multi-user authentication

`LoginScreen -> SessionManager -> GoogleAuthService -> Google Sign-In` creates a Google-backed session. `SecureSessionRepository` stores only session metadata in secure storage. The Google ID token is not persisted. Existing email login remains a local/testing fallback and is not the intended public account flow.

## Monetization foundation

`SubscriptionService -> MonetizationConfig` defines Free/Basic/Pro/Unlimited while feature flags keep paid tiers disabled during pilot. `PaymentGateway` is a provider-neutral backend contract; payment credentials must never be placed in the mobile client.

## Shared AI target

For a multi-user production service, the mobile client should send a verifiable Google identity token over HTTPS to a FinChat backend/AI gateway. The backend verifies identity, resolves entitlement/rate limits, and calls the Gemini/API provider using a server-side secret. The Android app must never contain the shared provider API key.
