# Phase 4 — AI fallback foundation

- **Status:** implementation started after Phase 3B fixed testing succeeded.
- Added a provider-agnostic AI category fallback contract.
- Added validation for AI category existence and confidence.
- Added transaction intelligence orchestration with local-first parsing and category learning.
- AI receives locally parsed transaction facts and may only suggest a category.
- Added unit tests covering valid, invalid, low-confidence, local-only, and fallback paths.
- No external AI provider or API key is introduced yet.

# Changelog

## 0.3.2 - 2026-09-26 - Phase 3B CI lint fix

- **Type:** fix / CI compatibility
- **Component:** `finchat_database.dart`, `sqlite_transaction_repository.dart`, database tests
- **Previous behavior:** GitHub Actions `flutter analyze` reported one `prefer_initializing_formals` issue, five missing `@override` annotations, and one unused test import, causing the analyze step to exit with code 1.
- **Exact change:** changed the database path constructor parameter to an initializing formal; added `@override` to all repository methods implementing the repository contract; removed the unused `database_schema.dart` test import.
- **Reason:** FinChat CI treats analyzer issues as a failed verification step.
- **Impact:** no runtime/database behavior changes; only analyzer-compliance corrections.
- **Migration:** none.
- **Tests:** GitHub Actions should rerun `flutter analyze`, `flutter test`, and the Android build.
- **Result:** pending GitHub Actions verification.
- **Status:** ready for CI.

## 0.1.0-phase2-v2 — 2026-09-25

### Type
Phase 2 foundation correction / CI and Git automation.

### Component
Flutter project structure, GitHub Actions, Windows upload automation, documentation.

### Previous problem / behavior
- The previous package did not provide a reliable GitHub-only Android build path when the `android/` platform folder was absent.
- The previous uploader stopped when local and remote `main` histories were unrelated, requiring manual `git pull --rebase`, which is not appropriate for unrelated initial commits.
- Local Flutter was unavailable, so local CLI verification could not be claimed.

### Exact change
- Added GitHub Actions test workflow using Flutter stable.
- Added Android build workflow with automatic `flutter create --platforms=android` when `android/` is missing.
- Added release workflow with the same Android bootstrap behavior.
- Replaced the uploader logic with a non-destructive history-aware flow: fetch, detect ancestor relationship, fast-forward when possible, otherwise merge with `--allow-unrelated-histories`; stop on conflicts; never force push.
- Added `.gitattributes` for predictable line endings.
- Added project continuation and implementation documentation.

### Reason
Allow the user to develop/build FinChat through GitHub without requiring a local Flutter installation while protecting existing GitHub history.

### Impact
- User can upload with `UPLOAD_TO_GITHUB.bat` even when GitHub already contains an initial commit.
- GitHub Actions can create Android platform files on the runner and build the APK.
- A merge conflict still requires human resolution; the script does not guess or overwrite files.

### Migration
Replace the old package with this package, or copy the new uploader/workflows/docs into the existing repository. If the local repository already has the old uploader, replace it with this version.

### Tests
Local Flutter `analyze/test/build` were not executed because Flutter SDK is not installed in the current build environment. CI workflows are configured to perform those checks on GitHub.

### Result
Implementation prepared; real CI result remains the source of truth after push.

### Status
Phase 2 remains active. Next: persistent secure session, local DB, migrations, real repositories.
## 0.1.0+2 — 2026-09-25

- **Type:** Fix / compatibility
- **Component:** `lib/presentation/navigation/app_router.dart`
- **Previous problem:** GitHub Actions `flutter analyze` failed because the router used deprecated `RouteInformation.location` and `Navigator.onPopPage`, plus a null-aware expression that could never execute.
- **Exact change:** Migrated route information handling to `RouteInformation.uri`; replaced `Navigator.onPopPage` with `Navigator.onDidRemovePage`; removed the obsolete null-aware expression.
- **Reason:** Current Flutter stable analysis treats these deprecated APIs as analyzer issues, and the CI workflow is configured to fail when analysis reports issues.
- **Impact:** The router remains functionally equivalent for the current single-root-page navigation model while using the current Flutter navigation APIs.
- **Migration:** No database or user-data migration required. Replace the router file and rerun GitHub Actions.
- **Tests:** `flutter analyze` is expected to be clean in GitHub Actions; local Flutter SDK is not available in the authoring environment.
- **Result:** Pending GitHub Actions verification.
- **Status:** Fixed in source package; CI verification pending.


## 0.2.0 — 2026-09-25 — Phase 3 Transaction Engine foundation

- **Type:** feature
- **Component:** local transaction parsing / amount recognition
- **Previous behavior:** Phase 2 only contained transaction domain contracts; no production local parser existed.
- **Change:** added `MoneyAmountParser` and `LocalTransactionParser`.
- **Amount formats:** `25 rb`, `25 ribu`, `25k`, `Rp 25.000`, `Rp25.000`, `1 juta`, `1,5 juta`, `1.5jt`, `2m`, and grouped Indonesian amounts such as `1.250.000`.
- **Multi-transaction:** one text input can yield multiple parsed transactions when multiple money expressions are present.
- **Reason:** Indonesian users commonly write monetary amounts using informal shorthand; parser behavior must be deterministic and offline-first before AI fallback.
- **Impact:** transaction text input now has a local parsing foundation and test coverage for common amount representations.
- **Migration:** none.
- **Tests:** added unit tests for money normalization and local transaction parsing.
- **Result:** pending GitHub Actions verification.
- **Status:** in progress — Phase 3 foundation.

## 0.3.1 - 2026-09-26 - Phase 3B Local Database, Repository, and Category Learning

- **Type:** feature / architecture
- **Component:** local SQLite database, transaction repository, category repository, category learning
- **Previous behavior:** Phase 3 had a working local parser, but parsed transactions did not yet have a persistent local database, repository-backed CRUD, or persistent user-specific category corrections.
- **Change:** added SQLite schema version 1 with users, categories, transactions, category_mappings, category_history, and app_settings; added seeded system categories; added transaction CRUD/query repository with soft delete; added category mapping/history repository and category learning service.
- **Reason:** FinChat is offline-first and must keep local data as the source of truth. Category consistency requires persistent user-specific learning before AI fallback is introduced.
- **Impact:** transactions and category preferences now have a defined persistence boundary. AI can later consume validated repository data without becoming the database owner.
- **Migration:** new installations create schema version 1. Future schema changes must use `onUpgrade` and must not destructively recreate user data.
- **Tests:** added SQLite repository/category tests using `sqflite_common_ffi` for CI-friendly database verification.
- **Result:** ready for GitHub Actions verification.
- **Status:** in progress until GitHub Actions passes; then Phase 3B is complete and Phase 4 AI Fallback can begin.
