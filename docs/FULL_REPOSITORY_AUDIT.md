## Verified GitHub CI — 0.3.2+12 (5 Oktober 2026)

- Tested code commit: `93ccf38c8a7d5e8be9e386d86321dd8f9bbaee8f`, branch `codex/finchat-input-navigation-audit`.
- Run https://github.com/rama160/Finchat/actions/runs/37293049436 — completed / success.
- Flutter stable 3.47.6: dependency resolution passed; `flutter analyze` No issues found; **94 tests passed**; release APK **92.0 MB** built successfully.
- APK artifact: https://github.com/rama160/Finchat/actions/runs/37293049436/artifacts/11337048743 (`finchat-audit-release-apk`). Permanent release keystore and build Google server client ID retained; no secrets changed.
- Regression coverage includes final-vs-partial speech callbacks, word/numeric amounts, local multi-item capture with zero AI calls, scoped nota and local saving tips, active token reuse/expiry/concurrent restoration/logout, daily view rollover preserving SQLite, daily expense zero buckets/total reconciliation, user error messages and existing Back navigation.
- First iteration had 86 passing / 1 failing word-number regression (hundred arithmetic), corrected. Second iteration passed 92 tests and signed build; final iteration adds daily-reset/error-message regressions and passes 94 tests and signed build.
- Main remains `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`; three original workflows, schema, database lifecycle and transaction repository unchanged. Docs-only follow-up uses `[skip ci]` and does not change tested code.
- **Device gate remains open:** actual receipt OCR/camera/attach, microphone recognition quality, live Google/Gateway token refresh and Drive must be tried on Android. CI and keep-rule mitigation do not prove the obfuscated native OCR NPE is resolved on the user's device.

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

# FinChat Full Repository Audit — 2026-10-05

## Hasil CI GitHub — 5 Oktober 2026

- Workflow: https://github.com/rama160/Finchat/actions/runs/37281161336 — SUCCESS.
- Commit kode teruji: d40976563b27c55395672c9428ef2c49ae4ea9cf, branch codex/finchat-input-navigation-audit.
- Flutter stable 3.47.6: pub get lulus; analyze No issues found; **84 tests passed**; release APK berhasil (91.8 MB).
- APK: https://github.com/rama160/Finchat/actions/runs/37281161336/artifacts/11332107826 (finchat-audit-release-apk).
- Signing memakai permanent FinChat release keystore; Google server client ID diberikan dari secret build. Tidak ada perubahan secrets.
- Perbaikan hasil CI: RootBackButtonDispatcher, callback void pada setState laporan, null-safe SQL acknowledgement; fixture tes widget memakai SQLite FFI tanpa isolate, runAsync untuk membuka DB, frame pump dan snackbar wait.
- Main dan tiga workflow lama tidak diubah. Workflow tambahan untuk validasi hanya aktif pada branch audit. Kamera/mic/OAuth/Gateway/Drive langsung pada Android masih membutuhkan QA perangkat; CI tidak membuktikan konektivitas layanan terdeploy.


## Current patch — 0.3.2+11 (2026-10-05)

Authoritative current audit: `AUDIT_0.3.2+11.md`. Fixes RouterDelegate navigatorKey/system Back, CI FFI factory setup, integrated local/AI questions, money-in-question routing, guarded camera/file pickers, voice cancel callbacks, Google Drive snapshot acknowledgements, bottom navigation reports and shared smart period filter. Transaction cards use gestures only; white rounded composer includes emoji/attachment/camera/mic/send.

SQLite schema and existing workflows unchanged. Source is matched to main commit `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Flutter SDK unavailable locally; CI and real Android device acceptance are required. Baseline CI had 72 passed / 1 failed (global FFI factory test setup); do not describe the baseline result as verification of this patch.


## Scope and verification boundary

This audit was performed against the uploaded ZIP file-by-file and then used to produce the cleaned 0.3.2+5 package and the 0.3.2+6 runtime bugfix. The artifact workspace has **no Flutter/Dart SDK**, so this package is not claimed to have passed `flutter analyze`, `flutter test`, or `flutter build apk --release` locally. GitHub Actions is the canonical compiler/test/build gate. A real Android-device pass is still mandatory for plugin and permission behavior.


## 0.3.2+6 runtime bugfix audit

- **Database:** `FinChatDatabase()` is now a shared production instance so `ChatScreen`, `ReportScreen`, `FinancialQaScreen` and `BackupScreen` cannot close each other's SQLite connection during `dispose()`. Custom test instances remain isolated.
- **Database:** open operations are serialized and a cached closed handle is reopened. No schema version or restore format changed.
- **AI:** normal `OpenAiCompatibleAiProvider()` no longer requires the legacy secure-storage `ai.enabled` flag. It reuses `GoogleSignInCoordinator` for the logged-in Google ID token and calls the existing Cloudflare Gateway.
- **Preserved:** Google Sign-In/session mapping and legacy-data restore behavior were not redesigned.
- **Verification:** source-level audit complete; GitHub Actions and Android-device tests remain required.

## Executive findings

- The upload contained source and Git history through Phase 12, but its handoff/status documents still opened at Phase 11.1.2 and contradicted the later code.
- The text transaction path already matched the most recent requirement: recognized transactions save immediately and expose Edit/Delete plus swipe-right Edit / swipe-left Delete.
- Several original PRD goals were only partial: file attachment receipts, pie visualization, per-category counts, income/expense drill-down, main-chat finance questions, and true automatic Drive backup.
- Build and release workflows duplicated Android mutation code and had different permission handling, creating avoidable release/runtime drift.
- The root contained phase copy notes and multiple BAT utilities that should not remain separate in the distributable project.

## Changes made by this audit package

- Added explicit receipt image-file attachment (JPG/JPEG/PNG/WEBP).
- Main composer now recognizes finance-style questions and opens Q&A with the question prefilled/auto-run. Voice questions use the same routing and reset voice state correctly.
- Common financial questions (pemasukan, pengeluaran, saldo, jumlah transaksi, largest expense category) are answered from local report data before AI.
- Reports now include a true expense pie chart, transaction count per category and drill-down from income/expense/category summaries.
- Automatic Drive backup now performs a first backup at enablement and is attempted on chat startup/data refresh; cloud failure does not block transaction capture.
- Moved initial transaction load from `initState` to `didChangeDependencies` to avoid unsafe inherited-context dependency lookup.
- Prevented Dismissible double-removal/race after swipe-delete.
- Consolidated Android CI configuration into `tooling/android/configure_android_ci.py` and made build/release use it.
- Consolidated Google setup docs, phase copy notes, and Windows GitHub utilities.

## Feature-to-goal audit

| Goal | Uploaded ZIP | Audit package | Remaining acceptance |
|---|---|---|---|
| Persistent login | Implemented | Retained | Google device/OAuth test |
| Text multi-transaction immediate save | Implemented | Retained | CI + device smoke test |
| Edit/Delete + swipe | Implemented; possible dismiss race | **Race hardened** | Device gesture UX |
| Indonesian shorthand money | Implemented + tests | Retained | CI tests |
| Category consistency/learning | Implemented | Retained | CI + correction flow |
| Voice → parser → DB | Implemented | Retained + question routing reset | Microphone/id_ID device test |
| Camera receipt preprocessing/OCR | Implemented | Retained | Real receipt QA |
| Receipt attachment | Gallery only | **Explicit image-file picker added** | Android file provider QA |
| Receipt multi-item review/save | Implemented | Retained | Real receipt QA |
| Expense pie chart | Not a pie chart | **Real pie chart added** | UI QA |
| Count per category | Model data only/incomplete UI | **Displayed per category** | UI QA |
| Tap income/expense → details | Missing | **Added** | UI QA |
| Extra chart + insight | Implemented | Retained | UI QA |
| PDF | Implemented | Retained | Android share QA |
| Main chat recognizes finance questions | Missing | **Added** | CI/UI QA |
| Offline/local Q&A | AI-centric | **Common questions local-first** | CI tests |
| Local backup/restore | Implemented | Retained | File/share device QA |
| Drive backup/restore | Implemented baseline | Retained | OAuth/Drive QA |
| Automatic backup | Preference only | **Operational after one-time authorization** | OAuth/network/device QA |
| Update checker | Implemented | Retained | Published release test |
| Android release config | Workflow drift | **Unified** | GitHub Actions |
| GitHub update + delete old files | Multiple scripts/no authoritative cleanup | **One manifest-driven BAT** | Windows execution |

## Repository cleanup

The distributable ZIP intentionally excludes `.git/`. Seven `PHASE_*_COPY_INSTRUCTIONS.md` files were merged into `docs/PHASE_11_12_IMPLEMENTATION_HISTORY.md`. Google Sign-In and Drive setup were merged into `docs/GOOGLE_ACCOUNT_AND_DRIVE_SETUP.md`. `RUN_PHASE_11_QA.bat`, `RUN_PHASE_12_QA.bat`, `UPLOAD_TO_GITHUB.bat`, and `scripts/*.bat` were replaced by `UPDATE_GITHUB.bat`. `tooling/repository_manifest.txt` makes the BAT able to delete tracked files from older repo layouts even when those stale files remain on disk after extraction.

## File-by-file inventory

| File | Purpose | Status | Finding / action |
|---|---|---|---|
| `.gitattributes` | Repository/analyzer configuration | **OK** | Configuration retained. |
| `.github/workflows/build_android.yml` | CI build Android | **IMPROVED** | Uses shared Android configurator; analyze/test/release APK remains the canonical CI gate. |
| `.github/workflows/flutter_test.yml` | CI analyze/test | **OK** | Runs pub get, analyze and unit/widget tests on push/PR. |
| `.github/workflows/release.yml` | GitHub Release APK | **IMPROVED** | Uses the same Android/R8/permission configurator as build; default release tag is v0.3.2. |
| `.gitignore` | Repository/analyzer configuration | **OK** | Configuration retained. |
| `Ai start here.md` | AI handoff entry point | **UPDATED** | Stale Phase 11.1.2 opening replaced with current 0.3.2+6 bugfix state and exact next gate. |
| `CHANGELOG.md` | Repository documentation | **UPDATED** | Retained and updated for this audit package. |
| `README.md` | Repository documentation | **UPDATED** | Retained and updated for this audit package. |
| `UPDATE_GITHUB.bat` | Single Windows GitHub synchronizer | **NEW** | Fetch/rebase, manifest-driven stale tracked-file cleanup, git add -A, commit and push; no force-push. |
| `analysis_options.yaml` | Repository/analyzer configuration | **OK** | Configuration retained. |
| `docs/AI_CONTRACT.md` | Project documentation | **RETAIN** | Retained as architecture/setup/history documentation; current truth defers to IMPLEMENTATION_STATUS and this audit. |
| `docs/ARCHITECTURE.md` | Project documentation | **UPDATED** | Retained; current truth includes the shared production database lifecycle and Gateway architecture. |
| `docs/BUGFIX_0.3.2+6_DATABASE_AI.md` | Runtime bugfix handoff | **NEW** | Records root causes, exact fixes, preserved workflows and verification gates for 0.3.2+6. |
| `docs/FINCHAT_MASTER_CONTEXT.md` | Project documentation | **RETAIN** | Retained as architecture/setup/history documentation; current truth defers to IMPLEMENTATION_STATUS and this audit. |
| `docs/FULL_REPOSITORY_AUDIT.md` | Authoritative detailed audit | **UPDATED** | Adds the 0.3.2+6 runtime bugfix findings and verification gates. |
| `docs/GOOGLE_ACCOUNT_AND_DRIVE_SETUP.md` | Google setup documentation | **CONSOLIDATED** | Merges the former Google Sign-In and Phase 11.5 Drive setup documents. |
| `docs/IMPLEMENTATION_STATUS.md` | Current implementation truth | **UPDATED** | Conflicting Phase 11/12 status replaced with current audit/package verification state. |
| `docs/MULTI_USER_AI_AND_MONETIZATION.md` | Project documentation | **RETAIN** | Retained as architecture/setup/history documentation; current truth defers to IMPLEMENTATION_STATUS and this audit. |
| `docs/PHASES.md` | Project documentation | **RETAIN** | Retained as architecture/setup/history documentation; current truth defers to IMPLEMENTATION_STATUS and this audit. |
| `docs/PHASE_11_12_IMPLEMENTATION_HISTORY.md` | Historical phase implementation notes | **CONSOLIDATED** | Merges seven root PHASE_*_COPY_INSTRUCTIONS files. |
| `docs/PHASE_11_7_E2E_MATRIX.md` | Project documentation | **RETAIN** | Retained as architecture/setup/history documentation; current truth defers to IMPLEMENTATION_STATUS and this audit. |
| `docs/PHASE_12_COMPLETION_REPORT.md` | Project documentation | **RETAIN** | Retained as architecture/setup/history documentation; current truth defers to IMPLEMENTATION_STATUS and this audit. |
| `docs/PHASE_12_HARDENING_MATRIX.md` | Project documentation | **RETAIN** | Retained as architecture/setup/history documentation; current truth defers to IMPLEMENTATION_STATUS and this audit. |
| `docs/PRD.md` | Project documentation | **RETAIN** | Retained as architecture/setup/history documentation; current truth defers to IMPLEMENTATION_STATUS and this audit. |
| `docs/ROADMAP_AUDIT.md` | Project documentation | **RETAIN** | Retained as architecture/setup/history documentation; current truth defers to IMPLEMENTATION_STATUS and this audit. |
| `docs/UPDATE_RELEASE.md` | Project documentation | **RETAIN** | Retained as architecture/setup/history documentation; current truth defers to IMPLEMENTATION_STATUS and this audit. |
| `docs/VOICE_INPUT.md` | Project documentation | **RETAIN** | Retained as architecture/setup/history documentation; current truth defers to IMPLEMENTATION_STATUS and this audit. |
| `integration_test/phase_11_end_to_end_test.dart` | Integration test shell | **PARTIAL** | Useful shell/navigation coverage but physical camera/mic/OAuth/OCR behavior still needs a real Android device. |
| `lib/application/ai/ai_secure_config_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/ai/financial_qa_service.dart` | Financial Q&A | **IMPROVED** | Answers common totals/saldo/count/top-category locally before AI fallback. |
| `lib/application/auth/google_auth_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/auth/google_sign_in_coordinator.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/backup/automatic_backup_service.dart` | Automatic Drive backup | **NEW** | Runs only when enabled and uses Drive appDataFolder; failures are isolated from transaction capture. |
| `lib/application/backup/backup_preference_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/backup/backup_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/backup/google_drive_auth_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/billing/monetization_config.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/billing/payment_gateway.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/billing/subscription_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/ocr/receipt_ocr_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/ocr/receipt_transaction_parser.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/reports/report_pdf_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/reports/report_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/session/session_manager.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/speech/voice_input_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/transactions/local_transaction_parser.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/transactions/transaction_intelligence_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/application/update/update_service.dart` | Application orchestration | **OK** | Coordinates domain/data behavior without direct AI-to-database writes. |
| `lib/core/constants/app_constants.dart` | Project file | **REVIEWED** | Reviewed in the repository inventory. |
| `lib/core/errors/app_failure.dart` | Project file | **REVIEWED** | Reviewed in the repository inventory. |
| `lib/core/validation/transaction_validator.dart` | Project file | **REVIEWED** | Reviewed in the repository inventory. |
| `lib/data/ai/openai_compatible_ai_provider.dart` | Infrastructure/data adapter | **FIXED** | Gateway-first production path now uses the shared Google Sign-In coordinator and no longer depends on the legacy local AI enable flag. |
| `lib/data/backup/google_drive_backup_provider.dart` | Infrastructure/data adapter | **OK** | Concrete SQLite/network/device implementation retained and connected through contracts where applicable. |
| `lib/data/local/database_schema.dart` | Infrastructure/data adapter | **OK** | Concrete SQLite/network/device implementation retained and connected through contracts where applicable. |
| `lib/data/local/finchat_database.dart` | Infrastructure/data adapter | **FIXED** | Production database handle is shared across screens; opening is serialized and stale closed handles are reopened. |
| `lib/data/ocr/image_receipt_preprocessor.dart` | Infrastructure/data adapter | **OK** | Concrete SQLite/network/device implementation retained and connected through contracts where applicable. |
| `lib/data/ocr/mlkit_receipt_ocr_provider.dart` | Infrastructure/data adapter | **OK** | Concrete SQLite/network/device implementation retained and connected through contracts where applicable. |
| `lib/data/repositories/in_memory_session_repository.dart` | Infrastructure/data adapter | **OK** | Concrete SQLite/network/device implementation retained and connected through contracts where applicable. |
| `lib/data/repositories/sqlite_category_repository.dart` | Infrastructure/data adapter | **OK** | Concrete SQLite/network/device implementation retained and connected through contracts where applicable. |
| `lib/data/repositories/sqlite_transaction_repository.dart` | Infrastructure/data adapter | **OK** | Concrete SQLite/network/device implementation retained and connected through contracts where applicable. |
| `lib/data/session/secure_session_repository.dart` | Infrastructure/data adapter | **OK** | Concrete SQLite/network/device implementation retained and connected through contracts where applicable. |
| `lib/data/speech/speech_to_text_provider.dart` | Infrastructure/data adapter | **OK** | Concrete SQLite/network/device implementation retained and connected through contracts where applicable. |
| `lib/data/update/github_release_update_provider.dart` | Infrastructure/data adapter | **OK** | Concrete SQLite/network/device implementation retained and connected through contracts where applicable. |
| `lib/domain/ai/ai_category_fallback.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/ai/financial_ai_provider.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/auth/google_auth_result.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/backup/backup_models.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/billing/subscription_models.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/entities/category_entity.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/entities/category_mapping.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/entities/session.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/entities/transaction_entity.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/ocr/receipt_image_preprocessor.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/ocr/receipt_ocr.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/parsing/money_amount_parser.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/reports/report_models.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/repositories/category_repository.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/repositories/session_repository.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/repositories/transaction_repository.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/services/category_learning_service.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/speech/speech_recognition.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/domain/update/app_update.dart` | Domain model/contract | **OK** | Core model/provider/repository contract remains separated from UI and concrete adapters. |
| `lib/main.dart` | Application bootstrap | **OK** | Initializes secure session and Google coordinator before MaterialApp router. |
| `lib/presentation/navigation/app_router.dart` | Authentication-root navigation | **OK** | Splash/login/chat root is derived from SessionManager state. |
| `lib/presentation/screens/backup_screen.dart` | Backup/restore UI | **IMPROVED** | Local and Drive backup/restore; enabling automatic backup now authorizes Drive, performs first backup and persists the setting. |
| `lib/presentation/screens/chat_screen.dart` | Main chat and transaction UI | **IMPROVED** | Immediate-save text/voice, edit/delete/swipe, camera/gallery/file receipts, finance-question routing, safe lifecycle initial load, category learning and automatic-backup trigger. |
| `lib/presentation/screens/financial_qa_screen.dart` | Financial Q&A screen | **IMPROVED** | Accepts and auto-runs questions routed from the main composer. |
| `lib/presentation/screens/login_screen.dart` | Flutter presentation | **OK** | UI layer retained; feature-specific findings appear in the feature matrix. |
| `lib/presentation/screens/receipt_review_screen.dart` | Flutter presentation | **OK** | UI layer retained; feature-specific findings appear in the feature matrix. |
| `lib/presentation/screens/report_screen.dart` | Reports UI | **IMPROVED** | Daily/range/month summaries, true expense pie chart, per-category counts, income/expense/category/group drill-down, insight and PDF share. |
| `lib/presentation/screens/settings_screen.dart` | Flutter presentation | **OK** | UI layer retained; feature-specific findings appear in the feature matrix. |
| `lib/presentation/screens/splash_screen.dart` | Flutter presentation | **OK** | UI layer retained; feature-specific findings appear in the feature matrix. |
| `pubspec.yaml` | Flutter dependencies/version | **IMPROVED** | Version 0.3.2+6; required SQLite/OCR/voice/PDF/Drive/auth/file dependencies retained. |
| `test/application/automatic_backup_service_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/backup_preference_service_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/backup_service_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/backup_snapshot_validation_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/financial_qa_service_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/ocr/receipt_ocr_service_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/ocr/receipt_transaction_parser_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/report_pdf_service_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/report_service_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/session_manager_google_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/session_manager_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/speech/voice_input_service_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/transaction_entry_flow_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/transaction_intelligence_service_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/application/transactions/local_transaction_parser_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/core/transaction_validator_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/data/openai_compatible_ai_provider_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/data/openai_phase12_hardening_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/data/sqlite_transaction_repository_phase12_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/data_database_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/domain/ai_category_fallback_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/domain/backup_models_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/domain/billing_subscription_models_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/domain/ocr/receipt_image_preprocessor_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/domain/parsing/money_amount_parser_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/domain/speech/speech_recognition_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/domain/update_service_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `test/widget_test.dart` | Automated regression test | **PRESENT** | Focused test retained; fresh GitHub Actions run is required after this package. |
| `tooling/android/configure_android_ci.py` | Shared Android CI configuration | **NEW** | Single source for minSdk, R8, camera/microphone/network/Bluetooth permissions, speech query and allowBackup=false. |
| `tooling/android/proguard-rules.pro` | R8 ML Kit rules | **OK** | Retains targeted optional-language dontwarn rules for Latin-only receipt OCR. |
| `tooling/repository_manifest.txt` | Authoritative distributable file manifest | **NEW** | Allows UPDATE_GITHUB.bat to delete tracked remote files that remain locally from older packages. |

## Static checks completed in artifact workspace

- All relative Dart imports resolve to existing files.
- Modified Dart files have balanced braces/parentheses/brackets under a structural check.
- `pubspec.yaml` and all GitHub workflow YAML files parse successfully.
- `tooling/android/configure_android_ci.py` passes Python compilation and was executed against a mock Kotlin-Gradle Android template; it correctly applied minSdk 23, R8 rules, permissions, speech query and `allowBackup=false`.
- `tooling/repository_manifest.txt` exactly matches the cleaned distributable file set.
- `UPDATE_GITHUB.bat` is stored with CRLF line endings for Windows.
- Flutter/Dart compiler execution is still unavailable locally, so these checks do not replace GitHub Actions.

## Mandatory gate for this exact package

1. Run `UPDATE_GITHUB.bat` from the extracted root. Review the printed add/modify/delete list before the push completes.
2. GitHub Actions must pass `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter build apk --release`.
3. On a real Android device verify: persistent login; Google Sign-In; text/voice multi-save; swipe edit/delete; camera; gallery and explicit image-file receipt attachment; OCR clear/blurred/multi-item receipts; report pie/count/drill-down/PDF; local backup/restore; Drive authorization/manual/automatic backup; finance questions from main chat; and update checker against a published release.

Until those gates pass, static audit status means structurally reviewed—not product acceptance.
