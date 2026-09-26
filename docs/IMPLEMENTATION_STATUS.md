# FinChat Implementation Status

## Current Phase

**Phase 4 — AI Fallback (provider-agnostic foundation)**

## Completed

- Phase 1 — Product definition and repository foundation.
- Phase 2 — Flutter foundation; GitHub Actions analyze/test/Android build passed.
- Phase 3 — Local transaction parser; Indonesian Rupiah shorthand is supported (`25 rb`, `25 ribu`, `25k`, `1,5 juta`, etc.).
- SQLite local database foundation using `sqflite`.
- Versioned database schema with non-destructive upgrade hook.
- Local tables for users, categories, transactions, category mappings, category history, and app settings.
- System category seed data.
- Transaction repository with CRUD, date-range, user, category queries, and soft delete.
- Category mapping repository with usage count and correction history.
- Category learning service with normalization, exact/token mapping lookup, user-correction priority, and fallback category support.
- SQLite FFI tests so the database/repositories are testable in GitHub Actions without an Android emulator.

## Verification

Phase 3B fixed package was tested successfully by the project owner. The database, repository, category-learning, and analyzer correction milestone is therefore treated as passed for the transition into Phase 4.

The local environment used to assemble this package does not contain the Flutter SDK, so no local `flutter analyze`, `flutter test`, or APK build is claimed here. GitHub Actions remains the canonical CI verification environment.

## Phase 4 Progress

- Added provider-agnostic `AiCategoryProvider` contract.
- Added `AiCategoryFallback` validation boundary.
- AI suggestions require an existing local category and minimum confidence.
- Added `TransactionIntelligenceService` so local parsing and category learning remain first.
- AI is triggered only when local category resolution is not confident enough.
- AI receives the locally parsed amount/type/description; it does not create transaction records.
- Added unit tests for accepted, rejected, low-confidence, local-only, and AI-fallback paths.

## Next Step

Run the complete Phase 4 test/analyze workflow in GitHub Actions. Only after that passes should a real AI provider adapter be introduced.

AI must remain fallback-only. It must never bypass local validation or write directly to the database.
