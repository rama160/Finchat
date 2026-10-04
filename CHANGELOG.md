# 0.3.2+7 — Analyzer Cleanup After Runtime Bugfix

- **Date:** 2026-10-05
- **User-reported CI result:** `flutter analyze` exited with code 1 because the runtime bugfix package still had two AI-provider analyzer findings and six unnecessary string-escape findings in its Gateway regression test.
- **Fix:** Kept the `idTokenProvider` constructor contract unchanged, exposed the same callback through the provider field without the `prefer_initializing_formals` finding, removed the unnecessary non-null assertion, and built the nested Gateway test JSON with `jsonEncode()` instead of escaped string literals.
- **Preserved:** Database lifecycle fix, Google Sign-In, restore from legacy data to current user data, local-first parsing, OCR, voice, reports, backup, Gateway endpoint, and GitHub Actions workflow were not redesigned.
- **Verification:** The reported analyzer findings are addressed at source level. Flutter/Dart SDK is unavailable in this artifact workspace, so the next required gate is GitHub Actions `flutter analyze`, `flutter test`, and release APK build.

# 0.3.2+6 — Runtime Bugfix: Shared SQLite Connection + Gateway AI

- **User-reported problems:** text, voice and receipt transaction capture showed `DatabaseException(error database_closed)`; AI reported as unavailable.
- **Database root cause:** multiple production screens each created a `FinChatDatabase()` for the same SQLite file and each screen called `close()` from `dispose()`. A screen lifecycle could therefore close a connection still needed by another async transaction flow.
- **Database fix:** production/default `FinChatDatabase()` now resolves to one shared application instance; its production `close()` is intentionally a no-op from screen lifecycle. Custom factory/path instances remain isolated for tests. Database opening is also serialized and stale closed handles are reopened defensively.
- **AI root cause:** the Gateway provider still checked the legacy secure-storage key `ai.enabled` before making any Gateway request. The production app constructs the provider without that legacy config, so this gate prevented Gateway calls.
- **AI fix:** production provider is now Gateway-first and obtains the Google ID token through the existing `GoogleSignInCoordinator`, avoiding a second hardcoded Google Sign-In initialization. The Cloudflare Gateway endpoint remains the existing endpoint and Gemini credentials remain server-side. Explicitly injected legacy config remains supported for existing tests.
- **Preserved workflows:** Google Sign-In, existing session/user mapping, restore from legacy data to current user data, local parser/category learning, OCR review, voice capture, reports, backup and release workflows are not redesigned.
- **Tests added:** production database instances share one handle; isolated test database instances remain separate; production Gateway provider can call the Gateway without the legacy local AI toggle.
- **Verification:** source-level audit completed; GitHub Actions `flutter analyze`, `flutter test`, and Android release build are required before calling this package CI-green.
- **Status:** ready for GitHub Actions verification and Android-device acceptance.

## Unreleased — Backup compatibility fix

- **Date:** 2026-10-04
- **Type:** Fix / backward compatibility
- **Previous problem:** Restoring an older FinChat JSON backup (`format: finchat_backup`, `version: 1`) failed with `FormatException: Struktur backup tidak valid` because the current restore parser only accepted the newer `format_version` + `tables` schema.
- **Change:** Added a backward-compatible migration for the original backup format, converting its transaction records and legacy categories into the current SQLite backup schema before restore. Legacy `local_user` data is rebound to the currently authenticated FinChat user during restore.
- **Impact:** Existing old local/Drive backup files can be restored without changing the current backup export format or transaction/business logic.
- **Migration:** Automatic at restore time; no manual conversion is required.
- **Tests:** Added coverage for restoring the original backup format and rebinding it to the current user. Fresh Flutter analyze/test verification must be run in GitHub Actions.
- **Status:** Ready for CI verification.

## Phase 11.1.2 — Fix `file_picker` 13 API Usage

- **Date:** 2026-09-29
- **Type:** Fix
- **Component:** `lib/presentation/screens/chat_screen.dart`, attachment receipt picker
- **Previous problem:** GitHub Actions `flutter analyze` failed because `FilePicker.platform` and the old `FilePickerResult`/`withData` API were still used while `pubspec.yaml` pins `file_picker: ^13.1.0`.
- **Change:** Migrated attachment picking to `FilePicker.pickFiles()`, which returns `List<PlatformFile>` in file_picker 13, and reads bytes with `PlatformFile.readAsBytes()` with a local-path fallback.
- **Reason:** Align the attachment implementation with the installed federated file_picker 13 API while preserving JPG/JPEG/PNG/WEBP receipt support.
- **Impact:** No change to OCR preprocessing, receipt parsing, transaction saving, category learning, or database behavior.
- **Migration:** None.
- **Tests:** GitHub Actions should rerun `flutter analyze`, `flutter test`, and `flutter build apk --release`.
- **Status:** Ready for CI verification.

# Changelog

## 0.3.2+8
- Fixed remaining Dart analyzer errors in `OpenAiCompatibleAiProvider` by properly initializing the optional ID-token callback field and promoting it before invocation.
- No established application workflow or business logic changed.


## 0.3.2+5 — Full Repository Audit, Cleanup, and PRD Gap Closure

- **Date:** 2026-09-29
- **Type:** Audit / integration / repository cleanup
- **Previous problem:** The uploaded repository had implementation through Phase 12 but stale Phase 11.1 handoff/status documents, multiple root phase-copy instruction files, multiple overlapping BAT utilities, divergent Android build/release configuration, and several original PRD gaps that were only partially implemented.
- **Changes:** Added a file-by-file repository audit; explicit image-file receipt attachment; main-chat financial-question recognition; local-first finance Q&A; true report pie chart, per-category counts and income/expense drill-down; operational automatic Drive backup after one-time authorization; safe inherited-context lifecycle loading; swipe-delete race hardening; shared Android CI configurator; and one `UPDATE_GITHUB.bat` that stages additions/updates/deletions without force-push.
- **Repository cleanup:** Consolidated `PHASE_11_2` through `PHASE_12` copy instructions into `docs/PHASE_11_12_IMPLEMENTATION_HISTORY.md`; removed obsolete QA/upload/status/release BAT helpers from the distributable package; excluded `.git` metadata from the cleaned ZIP.
- **Build metadata:** Version advanced from `0.3.1+4` to `0.3.2+5`; release workflow default tag aligned to `v0.3.2`.
- **Data/schema impact:** No SQLite schema migration; existing transaction/user/category/backup data format remains unchanged.
- **Verification:** Static repository audit and Python build-tool syntax check completed in the artifact environment. Flutter/Dart SDK is unavailable here, therefore fresh GitHub Actions analyze/test/release build and real-device acceptance are mandatory.
- **Status:** Ready for GitHub CI verification.

# Phase 12 Google Auth — widget test correction

- Updated `test/widget_test.dart` to match the Google Sign-In login UI (`Lanjut dengan Google` and `Masuk tanpa Google`).
- No application runtime logic was changed.
- **Status:** prepared for GitHub Actions `flutter test` and release verification.

# Phase 12 Google Auth — CI analyzer correction

- Fixed `google_sign_in` 7.x compatibility by replacing the removed `GoogleSignIn.currentUser` access with `attemptLightweightAuthentication()` in the Google Drive authorization service.
- Fixed analyzer `prefer_initializing_formals` findings in `GoogleSignInCoordinator` and `SessionManager` without changing runtime behavior.
- Added curly braces around transaction validation flow in `SqliteTransactionRepository`; transaction validation and atomic save behavior remain unchanged.
- **Status:** source correction prepared for GitHub Actions `flutter analyze`, `flutter test`, and release APK verification.

# Phase 11.3 — Voice transaction integration

- Added microphone input to the existing transaction composer.
- Indonesian speech recognition uses the existing `speech_to_text` adapter and `VoiceInputService`.
- Voice transcripts reuse `TransactionIntelligenceService`, local parsing, category learning, and AI fallback rules.
- Persisted voice transactions use `InputSource.voice`.
- Added UI state notifications to `VoiceInputService` and test coverage for locale/state propagation.
- Physical-device microphone testing is deferred to the final Phase 11 QA cycle by design.

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


### Phase 11.2 OCR test correction
- Fixed receipt quantity-line parsing so the final monetary value is persisted as the transaction amount while the full item description remains intact.
- No database schema change and no change to the OCR provider/preprocessing flow.


## Phase 11.4
- Added report category aggregation and transaction detail data.
- Added category/count visual summaries, insight, drill-down, empty/loading/error states.
- Enhanced PDF with category summary.
- No SQLite schema change.


## Phase 11.5
- Added local backup export/import UI.
- Added Google Sign-In + Drive appDataFolder integration.
- Added restore confirmations and backup status/error handling.
- Added persisted automatic-backup preference.


## Phase 11.6
- Added OpenAI-compatible AI provider adapter.
- Added secure AI configuration UI/storage.
- Wired configured AI as category fallback only.
- Added financial Q&A using application-computed report data.
- Added offline/malformed-response safe fallback.


## Phase 11.7
- Added Phase 11 E2E QA matrix.
- Added integration-test shell for authenticated application shell.
- Added Windows `RUN_PHASE_11_QA.bat` for analyze/test/release build sequence.
- Device verification remains explicitly pending.

## Phase 11 — CI analyzer correction after 11.4–11.7 merge
- Fixed the Phase 11 end-to-end integration test by importing `flutter/material.dart` for `TextField`.
- Removed the unused Google Drive API import from `GoogleDriveAuthService`.
- Corrected three unbalanced widget expressions in `report_screen.dart` without changing report behavior.
- Updated `ReportPdfService` tests for the current `ReportSummary` contract (`transactions` and `categories`).
- Updated OpenAI-compatible provider tests to use the current `AiSecureConfigService(store: ...)` parameter.
- Status: source corrections prepared; GitHub Actions `flutter analyze`, full test suite, and release build remain the verification gate.


## Phase 12 — Production Hardening
- Added transaction validation and atomic multi-transaction persistence.
- Added backup structure validation before restore.
- Added AI HTTPS requirement, timeout and response-size safeguards.
- Hardened login, report PDF export, backup import and transaction edit/delete error handling.
- Advanced application version to `0.3.0+3`.
- Added Phase 12.1–12.8 hardening matrix.

## Google OAuth build configuration audit
- GitHub Android build now passes `FINCHAT_GOOGLE_SERVER_CLIENT_ID` through a GitHub Actions secret.
- Release workflow default tag updated to `v0.3.1` to match app version `0.3.1+4`.
- No transaction, SQLite, OCR, voice, report/PDF, backup core, or AI hardening source was changed by this audit.

## Multi-user account & monetization foundation
- Added Google Sign-In to the application session flow.
- Added secure session metadata for authentication provider, Google user ID and display name.
- Preserved normalized email as the local user key to avoid breaking existing user-scoped SQLite data.
- Added Free, Basic, Pro and Unlimited subscription models.
- Added payment method foundation for QRIS, GoPay, bank transfer, card and other e-wallets.
- Added disabled monetization/payment feature flags for the pilot period.
- Added Google Sign-In setup and multi-user AI/monetization architecture documentation.
- Advanced app version to 0.3.1+4.
