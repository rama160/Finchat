## Device UX follow-up — 0.3.2+14 (5 Oktober 2026)

- Chat: transaksi dan Q&A tersusun berdasarkan waktu dalam satu timeline; pesan baru muncul paling bawah. Input dan status memiliki tinggi tetap, fokus/keyboard dipertahankan saat kirim, dan draft berikutnya tidak dikosongkan setelah proses sebelumnya selesai.
- Halaman Input tidak memiliki filter tanggal. Periode pertanyaan dibaca dari teks (hari/rentang/bulan/tahun); tanpa periode eksplisit, pertanyaan memakai seluruh riwayat. Daftar transaksi harian tetap reset tampilan saat berganti hari tanpa menghapus database.
- Header filter Laporan tetap sama; klik langsung membuka kalender Minggu–Sabtu dengan pilihan tanggal, rentang, bulan dan tahun. Satu bulan/tahun lengkap dikenali otomatis.
- Keterangan grafik berada di bawah grafik dan merangkum data, bukan fungsi. Total, pie, PDF dan insight tetap mengikuti periode; grafik satu hari tetap membandingkan dengan hari sebelumnya.
- Insight: arus kas, rata-rata belanja termasuk hari nol, puncak belanja, perubahan harian dan transaksi berulang/ukuran transaksi. Tidak menyimpulkan kondisi pendapatan keseluruhan saat pemasukan belum tercatat.
- Suara: sesi dictation, nominal kata/angka dan harga tanpa pemisah diproses lokal sebagai multi transaksi. Batas durasi/pause tetap dapat dibatasi Android; kualitas mic harus diuji di HP.
- Struk: satu batch category learning, tanpa parse ulang tiap produk, recognizer dipakai ulang selama layar hidup; resize kamera mengikuti batas OCR dan file sementara tidak memakai fsync. Review dan koreksi kategori tetap wajib. Tidak ada klaim pengurangan latency HP sebelum pengukuran perangkat.
- Schema, lifecycle database, money parser, transaction repository, OAuth/secrets, endpoint Gateway dan workflow asli dipertahankan.
- Status verifikasi patch ini: menunggu CI analyze/tests/signed APK. Tes regresi mencakup keyboard/fokus/posisi input, draft berikutnya, urutan chat, kalender, scope pertanyaan, insight, multi suara dan batch struk.
- Gateway terpisah telah diperbarui ke 0.1.1 dan live provider berhasil HTTP200/622 ms, endpoint probe dihapus. Bukti https://github.com/rama160/AI-Gateway/actions/runs/37316536289 . Catatan lama “belum deploy/HTTP403” di bawah adalah riwayat dan sudah digantikan hasil Gateway terbaru.

## Verified GitHub CI — 0.3.2+13 (5 Oktober 2026)

- Tested code commit `02ea7a394e0af7afaedc85db5f44bf1ccef4aec3`, branch `codex/finchat-input-navigation-audit`.
- Run https://github.com/rama160/Finchat/actions/runs/37301937885 — success. Flutter stable 3.47.6: dependency resolution passed; analyze No issues found; **100 tests passed**; signed release APK **92.2 MB** built.
- APK: https://github.com/rama160/Finchat/actions/runs/37301937885/artifacts/11341239451 . Signing keystore and Google server client ID retained; no secrets changed.
- Regressions: Mahkota separate/noisy/column OCR and plain prices; exact keyword nota with zero AI calls; persistent typed categories and learning; inline save status; delete cancellation/confirmation; two-day comparison across year boundary; existing speech/token/Drive/storage/navigation tests.
- Gateway recovery snapshot: https://github.com/rama160/Finchat/actions/runs/37302216708 — npm ci, typecheck, lint, **17 tests** and Wrangler dry-run passed. Full corrected backend plus exact tested lockfile is included in the ZIP's separate AI-Gateway folder.
- GitHub write to rama160/AI-Gateway was rejected HTTP403 Resource not accessible by integration. No Gateway repo update or Cloudflare deployment occurred; live HTTP503 is not claimed resolved. Its main remains b7769af739b1550667c5a75e524d3d62e8f8a324.
- Finchat main remains 91252bddf4a4eadaa99dafe095f72c2e04a4bab1. Original three workflows, SQLite schema/lifecycle, money parser and transaction repository are byte-identical. Temporary backend snapshot validation is isolated in `codex/gateway-recovery-validation`; source ZIP retains the original workflow files.
- First run stopped on a redundant assertion warning, corrected. Second run exposed duplicate IDs caused by the test's frozen clock; its second input now advances the clock. Final suite and signed build passed. No product transaction-ID contract change.
- **Device/live gate open:** actual camera/attach OCR quality, Google/Gemini/Drive and report chart on Android must be retested. The fixture yields three products/Rp69.059; it is not a claim of real-device OCR success.
- This section supersedes older “verification pending” entries below. Final docs-only follow-up does not alter tested application code.

## Device receipt follow-up — 0.3.2+13 (5 Oktober 2026)

- Receipt parser joins product names with quantity/price rows, restores OCR column reading order from image coordinates, and excludes payment/header/footer rows. Mahkota Mart fixture: 3 items, Rp69.059; no payment or change recorded.
- Save success appears inline above the composer. Swipe delete requires explicit Hapus confirmation; Batal preserves data.
- Category edit accepts typed names and existing choices, persists custom categories without schema migration, and reuses the existing per-user correction learning.
- Single-day chart compares the previous day and selected day. Summary, pie and PDF retain the selected period only; date ranges/months retain daily buckets.
- Exact question “berapa total pengeluaran dengan kata acara, buat dalam bentuk nota” is answered locally from matching descriptions; it no longer requires Gateway.
- AI 503 remains an upstream operational issue until a corrected Gateway is deployed and tested against the real provider. Android OCR quality/camera/attach still requires device validation.
- Verification pending GitHub analyze/tests/signed APK. Original workflows, schema, database lifecycle, money parser and transaction repository retained.

## Verified GitHub CI — 0.3.2+12 (5 Oktober 2026)

- Tested code commit: `93ccf38c8a7d5e8be9e386d86321dd8f9bbaee8f`, branch `codex/finchat-input-navigation-audit`.
- Run https://github.com/rama160/Finchat/actions/runs/37293049436 — completed / success.
- Flutter stable 3.47.6: dependency resolution passed; `flutter analyze` No issues found; **94 tests passed**; release APK **92.0 MB** built successfully.
- APK artifact: https://github.com/rama160/Finchat/actions/runs/37293049436/artifacts/11337048743 (`finchat-audit-release-apk`). Permanent release keystore and build Google server client ID retained; no secrets changed.
- Regression coverage includes final-vs-partial speech callbacks, word/numeric amounts, local multi-item capture with zero AI calls, scoped nota and local saving tips, active token reuse/expiry/concurrent restoration/logout, daily view rollover preserving SQLite, daily expense zero buckets/total reconciliation, user error messages and existing Back navigation.
- First iteration had 86 passing / 1 failing word-number regression (hundred arithmetic), corrected. Second iteration passed 92 tests and signed build; final iteration adds daily-reset/error-message regressions and passes 94 tests and signed build.
- Main remains `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`; three original workflows, schema, database lifecycle and transaction repository unchanged. Docs-only follow-up uses `[skip ci]` and does not change tested code.
- **Device gate remains open:** actual receipt OCR/camera/attach, microphone recognition quality, live Google/Gateway token refresh and Drive must be tried on Android. CI and keep-rule mitigation do not prove the obfuscated native OCR NPE is resolved on the user's device.

## Follow-up regression coverage

- Android stopped/notListening status no longer submits an unfinished voice transcript; final nominal is required. Regression tests reproduce partial "nasi" arriving before final "nasi 10 ribu".
- Google ID-token session tests cover cached-login reuse, expiry/malformed tokens, single restoration for concurrent calls, sign-out and late restoration rejection. Cache remains in memory and no Google token is written to documentation/storage/logs.
- New widget regression verifies next-day resume hides previous-day items without deleting SQLite history.
- Initial device-patch CI: analyze passed, 86 passed/1 failed (word-number hundred arithmetic); corrected and re-run. Final results are recorded at the top of this document.

## Device follow-up — 0.3.2+12 (5 Oktober 2026)

- Capture teks/suara/struk kini menggunakan parser dan mapping lokal tanpa HTTP AI per item; mapping dibaca sekali per input. AI Q&A tetap tersedia sebagai fallback.
- Normalisasi nominal suara mendukung "nasi sepuluh ribu" serta "nasi 10 ribu".
- Provider AI menggunakan akun Google hasil authenticate yang diingat coordinator sebelum mencoba restorasi lightweight; JWT kedaluwarsa tidak digunakan dan cache dibersihkan saat sign-out.
- Pertanyaan nota dengan kata kunci menghitung dan merinci hanya deskripsi yang cocok; saran hemat dasar dapat dijawab lokal. Kendala yang belum didukung tidak diam-diam dijawab sebagai total keseluruhan.
- Input default hari ini; midnight/resume mengatur ulang tampilan harian dan Q&A tanpa menghapus data SQLite. Pertanyaan dan jawaban memakai bubble terpisah.
- Laporan mempertahankan total berdasarkan periode dan pie chart; bagian jumlah/detail transaksi di bawah chart diganti grafik pengeluaran harian. Hari tanpa pengeluaran bernilai nol; rentang/bulan mengikuti filter.
- Preprocessing gambar dipindahkan ke isolate. Error OCR tidak menampilkan stack trace di layar; cleanup recognizer tidak menimpa hasil. Keep rules native ML Kit/component registrar diperkuat untuk release.
- Tidak ada perubahan schema, database lifecycle, Drive backup, endpoint Gateway, secrets, atau tiga workflow asli. Perubahan login terbatas pada penyimpanan akun aktif, bukan alur pemilihan akun.
- Status: source patch teruji pada CI 37293049436; lihat hasil terbaru di atas. OCR native dan AI live perlu tes perangkat. Screenshot stack trace terobfuscate tidak cukup untuk memastikan akar NPE; keep rules adalah mitigasi release, bukan klaim hasil perangkat.

## 0.3.2+10 — Database test initialization fix

## Hasil CI GitHub — 5 Oktober 2026

- Workflow: https://github.com/rama160/Finchat/actions/runs/37281161336 — SUCCESS.
- Commit kode teruji: d40976563b27c55395672c9428ef2c49ae4ea9cf, branch codex/finchat-input-navigation-audit.
- Flutter stable 3.47.6: pub get lulus; analyze No issues found; **84 tests passed**; release APK berhasil (91.8 MB).
- APK: https://github.com/rama160/Finchat/actions/runs/37281161336/artifacts/11332107826 (finchat-audit-release-apk).
- Signing memakai permanent FinChat release keystore; Google server client ID diberikan dari secret build. Tidak ada perubahan secrets.
- Perbaikan hasil CI: RootBackButtonDispatcher, callback void pada setState laporan, null-safe SQL acknowledgement; fixture tes widget memakai SQLite FFI tanpa isolate, runAsync untuk membuka DB, frame pump dan snackbar wait.
- Main dan tiga workflow lama tidak diubah. Workflow tambahan untuk validasi hanya aktif pada branch audit. Kamera/mic/OAuth/Gateway/Drive langsung pada Android masih membutuhkan QA perangkat; CI tidak membuktikan konektivitas layanan terdeploy.


## Current patch — 0.3.2+11 (2026-10-05)

Authoritative current audit: `docs/AUDIT_0.3.2+11.md`. Fixes RouterDelegate navigatorKey/system Back, CI FFI factory setup, integrated local/AI questions, money-in-question routing, guarded camera/file pickers, voice cancel callbacks, Google Drive snapshot acknowledgements, bottom navigation reports and shared smart period filter. Transaction cards use gestures only; white rounded composer includes emoji/attachment/camera/mic/send.

SQLite schema and existing workflows unchanged. Source is matched to main commit `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Flutter SDK unavailable locally; CI and real Android device acceptance are required. Baseline CI had 72 passed / 1 failed (global FFI factory test setup); do not describe the baseline result as verification of this patch.

- Fixed the production `FinChatDatabase` singleton being created eagerly before `sqflite_common_ffi` initializes `databaseFactory` in Flutter tests.
- Production singleton is now lazy; this preserves the shared production connection/lifecycle fix while allowing FFI tests to call `sqfliteFfiInit()` before the first production database instance is constructed.
- No schema, transaction, restore, authentication, OCR, voice, AI Gateway, or GitHub workflow behavior changed.


## 0.3.2+9 — Analyzer fix
- Fixed `OpenAiCompatibleAiProvider` constructor initialization by using an initializing formal for `_idTokenProvider`.
- Fixed nullable token-provider invocation with explicit local promotion before invocation.
- No change to transaction, restore, Google Sign-In workflow, database schema, OCR, voice, Gateway endpoint, or CI workflow.
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
