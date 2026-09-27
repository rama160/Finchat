# Changelog

## Phase 11.2 — Receipt/OCR integration started
- Added camera/gallery receipt capture flow.
- Reused existing image preprocessing and ML Kit OCR baseline.
- Added receipt line-item parser and total/payment-line filtering.
- Added multi-transaction review/edit before persistence.
- Added category-learning feedback from review corrections.
- Added parser tests.

## Phase 11.1.2 — Fix GitHub Actions analyzer errors

- **Status:** Fixed in source; ready for GitHub Actions verification.
- **Scope:** `lib/presentation/screens/chat_screen.dart`
- **Fixes:**
  1. Added the `local_transaction_parser.dart` import so `ParsedTransactionType` used by the immediate-save mapping is defined.
  2. Replaced deprecated `DropdownButtonFormField.value` with `initialValue` for transaction type and category fields.
  3. Renamed the date formatter call from `_date(_date)` to `_formatDate(_date)` to avoid invoking the `_date` `DateTime` state field as a function.
- **Expected result:** `flutter analyze` should no longer report the four Phase 11.1.1 errors/info items previously observed in `chat_screen.dart`.
- **Verification:** Source-level checks completed; run GitHub Actions `flutter analyze`, `flutter test`, and release build after pushing.

# FinChat Changelog

Format: version/phase, problem or previous behavior, exact change, reason, impact, migration, tests/result, status.

## Unreleased — Phase 10

### Phase 10 — Update & Release + Documentation Reconciliation
- **Previous behavior:** session state was stored by `InMemorySessionRepository`, so closing the app lost the login session.
- **Change:** added `SecureSessionRepository` using `flutter_secure_storage` and wired it into `main.dart`.
- **Reason:** satisfy the persistent-session requirement and avoid asking the user to log in after every app close.
- **Impact:** session survives application restarts; logout still clears it.
- **Migration:** no existing database migration required; the previous session implementation was in-memory only.
- **Tests:** session behavior remains covered by application tests; CI verification required for the new plugin dependency.
- **Status:** implementation complete; GitHub Actions verification pending.

### Phase 10 — Update checker
- **Previous behavior:** the app had a release workflow but no in-app way to know whether a newer release existed.
- **Change:** added `UpdateService`, `GitHubReleaseUpdateProvider`, semantic version comparison, and Settings UI.
- **Reason:** connect the product requirement "app can be updated when changes are released" to the existing GitHub release pipeline.
- **Impact:** Settings can check the public `rama160/Finchat` latest release and open its release page.
- **Migration:** none.
- **Tests:** provider is isolated behind an interface so CI can use fakes; GitHub Actions must verify the package build.
- **Status:** implementation complete; self-install APK is intentionally deferred.

### Phase 10 — Version/release alignment
- **Change:** application version moved from `0.1.0+1` to `0.2.0+2`; release workflow default tag moved to `v0.2.0`.
- **Reason:** make the update checker and release artifact versioning coherent.
- **Impact:** future releases can be compared semantically.
- **Migration:** future database schema changes must use explicit SQLite migrations; Phase 10 changes do not alter the schema.
- **Status:** implementation complete; CI pending.

### Phase 10 — Documentation audit
- **Previous behavior:** source code had reached Phase 9 while `README.md`, `Ai start here.md`, and parts of `IMPLEMENTATION_STATUS.md` still described Phase 2 as current; changelog history was incomplete.
- **Change:** added `docs/ROADMAP_AUDIT.md` and reconciled all handoff documents through Phase 10.
- **Reason:** another AI must be able to continue from the repository without relying on chat history.
- **Impact:** technical completion and product-level completion are now explicitly separated.
- **Status:** complete.

## Phase 9 — Backup & Google Drive Sync
- Added versioned JSON snapshots covering local SQLite tables.
- Added transactional local restore.
- Added provider-agnostic cloud backup/restore contract.
- Added Google Drive `appDataFolder` provider that replaces the existing FinChat backup file instead of creating uncontrolled duplicates.
- Added backup serialization, restore, provider-requirement and fake-cloud tests.
- **Result:** project owner reports Phase 9 GitHub Actions success.
- **Known carry-over:** OAuth/account setup, automatic backup/restore triggers, manual backup/restore UI and conflict UX remain product backlog.

## Phase 8 — PDF Export
- Added A4 PDF generation from Phase 7 report data.
- Included period, income, expense, balance, transaction count and grouped details.
- Added PDF export/share action.
- Added PDF generation and filename tests.
- **Result:** project owner reports Phase 8 analyze/test success (35 tests at that milestone).

## Phase 7 — Reports & Analytics
- Added report models and service for daily, custom range and monthly reports.
- Added grouping by normalized description, transaction type and category.
- Added transaction count and combined amount.
- Added report screen and navigation.
- Added tests for grouping and date boundaries.
- **Known carry-over:** pie chart/category visualization, insight chart and transaction drill-down still need implementation.

## Phase 6 — Voice Input
- Added provider-agnostic speech contract.
- Added `speech_to_text` adapter and voice application service.
- Added Android speech permissions/recognition-service configuration in CI build.
- Added fake-provider tests.
- **Result:** project owner reports Phase 6 analyze success and 28 tests passing at that milestone.
- **Known carry-over:** product UI/device acceptance still required.

## Phase 5 — Receipt/OCR
- Added receipt image preprocessing with orientation correction, adaptive resize, grayscale/contrast processing and JPEG compression before OCR.
- Added ML Kit OCR adapter and provider-agnostic OCR contract.
- Added OCR service that writes only a temporary processed image and cleans it up afterward.
- Added CI-safe tests.
- **Known carry-over:** camera/file input UI and receipt line-item/multi-transaction parser/review remain required.

## Phase 4 — AI Fallback
- Added AI category fallback contract and transaction intelligence orchestration.
- Enforced local parser/category learning before AI fallback.
- Added confidence-based fallback and safe manual processing when AI returns no suggestion.
- Added tests for AI fallback and orchestration.
- **Known carry-over:** no concrete AI provider is committed; financial chat Q&A is not yet end-to-end.

## Phase 3B — Database + Repository + Category Learning
- Added SQLite schema for users, categories, transactions, mappings, history and settings.
- Added transaction and category repositories.
- Added category learning with normalized user mappings, confidence, usage count and history records.
- Added soft-delete for transactions.
- Added CI-safe SQLite tests.
- Fixed analyzer override/initializing-formal issues and category-learning test setup/history IDs.
- **Result:** project owner reports Phase 3B CI success.

## Phase 3 — Transaction Parser
- Added Indonesian monetary parsing for informal forms including `25 rb`, `25 ribu`, `25k`, `Rp25.000`, `1 juta`, `1,5 juta`, `1.5jt`, `2m` and grouped numeric amounts.
- Added multiple-transaction extraction baseline.
- Added parser and money parser tests.

## Phase 2 — Flutter Foundation
- Added Flutter project structure, Material 3 foundation, session manager, navigation and baseline screens.
- Added GitHub Actions for analyze/test and Android release build.
- Added safe Windows GitHub uploader that avoids force-push and stops on merge conflicts.
- Fixed deprecated router APIs (`location`/`onPopPage`) so analyze passes.

## Phase 1 — Product Definition & Repository Foundation
- Added PRD, architecture, phases, AI contract, implementation status, GitHub scripts and CI workflow baseline.
- Established offline-first/local-source-of-truth, parser-first/AI-fallback, migration, backup, changelog and safe Git automation rules.

## Changelog discipline

Every meaningful future change must record:
- previous behavior/problem;
- exact change;
- reason;
- impacted components/files;
- migration/data impact;
- tests and verification result;
- current status and known carry-over.

## Phase 10.1 — Analyzer Fix: Database Constructor Callsite

- **Date:** 2026-09-27
- **Type:** Fix
- **Component:** `FinChatDatabase`, backup service tests
- **Previous problem:** CI reported `undefined_named_parameter` because `backup_service_test.dart` still called the private constructor parameter `_databasePath`.
- **Change:** Exposed the constructor argument as public `databasePath` while keeping the internal `_databasePath` field private, and updated the test callsite.
- **Reason:** Dart analyzer requires the callsite to use the public parameter name.
- **Impact:** No runtime behavior change; in-memory backup tests continue to use `:memory:`.
- **Migration:** None.
- **Tests:** Pending GitHub Actions verification.
- **Status:** Ready for CI.

## Phase 10.2 — Analyzer Fix: Initializing Formal

- **Previous problem:** CI reported `prefer_initializing_formals` for the `FinChatDatabase` constructor because the public `databasePath` parameter was copied into a separate private field.
- **Change:** `databasePath` is now an initializing formal (`this.databasePath`) and the database path lookup uses that field directly.
- **Reason:** Satisfy the analyzer without changing database behavior or the public constructor callsite.
- **Impact:** No schema, migration, repository, backup, or runtime behavior change.
- **Tests:** GitHub Actions must rerun `flutter analyze`, `flutter test`, and Android build after this change.
- **Status:** Ready for CI verification.


## Phase 10.3 — Release Build Fix: ML Kit R8 Optional Languages

- **Date:** 2026-09-27
- **Type:** Fix
- **Component:** Android release workflow, ML Kit OCR
- **Previous problem:** GitHub Actions passed `flutter pub get`, `flutter analyze`, and `flutter test`, but `flutter build apk --release` failed at `:app:minifyReleaseWithR8` because R8 reported missing optional ML Kit Chinese, Devanagari, Japanese and Korean recognizer classes.
- **Change:** Added targeted R8 `-dontwarn` rules for the four optional non-Latin ML Kit language packages and made both Android build/release workflows copy those rules into the generated Android project before the release build.
- **Reason:** FinChat's current receipt OCR provider explicitly defaults to `TextRecognitionScript.latin`, which is appropriate for Indonesian receipts. Bundling all four optional language packages would increase APK size unnecessarily.
- **Impact:** Release R8 can ignore absent optional language classes while retaining Latin OCR. No transaction parser, database, schema, backup, or user-data behavior changes.
- **Migration:** None.
- **Tests:** GitHub Actions must rerun `flutter analyze`, `flutter test`, and `flutter build apk --release`. Local Flutter verification is not available in this environment.
- **Future note:** If FinChat later enables Chinese, Devanagari, Japanese or Korean OCR, replace the corresponding `-dontwarn` treatment with the official ML Kit language dependency for that script.
- **Status:** Ready for CI verification.


## Phase 10.4 — Robust Android R8 Workflow Fix

- Previous problem: the CI R8 configuration assumed `android/app/build.gradle` existed. The Android project can be generated by Flutter during CI and newer Flutter templates may use `build.gradle.kts`, causing `FileNotFoundError`.
- Change: CI now verifies the actual Android app Gradle file (`build.gradle` or `build.gradle.kts`) before configuring R8 and supports both Gradle file formats.
- Reason: prevent the R8 configuration step from failing before the release build reaches Gradle/R8.
- Impact: no Dart, database, parser, OCR, or transaction behavior change.
- Tests: GitHub Actions must rerun analyze, test, and release APK build.
- Status: Ready for CI verification.


## Phase 11.1 — Transaction End-to-End Vertical Slice

- **Date:** 2026-09-27
- **Type:** Feature / integration
- **Component:** Chat transaction entry, transaction intelligence, SQLite repository, category learning
- **Previous behavior:** `ChatScreen` was only a placeholder greeting and did not send user input through the parser or persist transactions.
- **Change:** Replaced the placeholder with a real text composer that invokes `TransactionIntelligenceService`, displays multiple parsed transactions as editable review cards, and saves confirmed transactions through `SqliteTransactionRepository`. Added editable nominal, description, type, category and date fields.
- **Reason:** Start Phase 11 with the most important PRD path: text transaction input must become reviewed local database records rather than stopping at an isolated parser/service.
- **Impact:** Users can enter examples such as `Beli nasi 25rb dan bensin 50k`, review the two resulting transactions, correct their categories, and save them locally. User category corrections are recorded for future resolution.
- **Migration/data impact:** Added `FinChatDatabase.ensureUser()` so the active session is represented in the local `users` table before a transaction is saved. No destructive schema change.
- **Tests:** Added `test/application/transaction_entry_flow_test.dart` covering multi-transaction parsing, SQLite persistence and category correction. GitHub Actions is the canonical verification environment.
- **Status:** Phase 11.1 implementation complete; CI verification required.

## Phase 11.1.1 — Immediate Transaction Save + Edit/Delete Gestures

- Previous behavior: parsed transactions were held in a review draft list and required a separate Save button.
- Change: normal text transaction input is now parsed and saved immediately to SQLite.
- Change: saved transactions expose Edit and Delete actions directly.
- Change: swipe right opens Edit; swipe left deletes the transaction.
- Change: editing can update description, amount, type, category, and date; category corrections are learned locally.
- Reason: match the intended FinChat chat workflow where transaction capture is immediate and post-save correction is lightweight.
- Impact: the normal text-entry path no longer uses a review-before-save screen. Future receipt/voice flows may still use specialized review where extraction confidence or user verification requires it.
- Example: `Beli nasi 25rb dan bensin 50k` is parsed into two transactions and both are immediately stored.
- Verification: GitHub Actions must run `flutter analyze`, `flutter test`, and `flutter build apk --release`.
- Status: Ready for CI verification.
