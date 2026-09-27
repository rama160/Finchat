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
