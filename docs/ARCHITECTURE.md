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
