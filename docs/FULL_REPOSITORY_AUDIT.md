# Detailed repository audit — Spenva 0.3.4+19

Audit date: 9 October 2026 UTC / 10 October Asia/Makassar. Repository `rama160/Finchat`. Canonical baseline `da61888d8151ee5bff52cea2a4cff846da8d5aa1` on `spenva-source-of-truth`. Old main `91252bdd...` is not the current product. This audit compares current source, tests, configuration, CI history, assets and documentation. It does not assert real-device or real-payment acceptance.

## Findings and fixes

| Finding | Consequence | Resolution / evidence |
|---|---|---|
| Main still old while PR4 contains canonical Spenva | Building wrong source drops branding, quota/privacy and input fixes | Patch based on canonical; entry points reconciled and uploader targets canonical branch |
| Last canonical CI: 133 passed, 1 failed, 2 skipped | Full preparation stopped before AAB | External-payment test now verifies no external checkout, matching canonical Play-only rule |
| JSON UTF-8 decoded as code points | Accents/non-Latin/emoji corrupted on local restore | `BackupService.restoreBytes` uses utf8.decode; same helper used by file picker; roundtrip regression |
| Snapshot tables read separately | Concurrent edits can create inconsistent cross-table backup | All six table reads inside one database transaction; cloud acknowledgement remains version-specific |
| Restore accepted duplicates, bad enum/type/reference data | Replace can silently lose rows or make later readers throw | Validate before any delete; identity/enum/column scalar/reference checks; insert-abort and existing rollback |
| Router configuration recreated on build; identical root page keys | Duplicate listeners/navigation lifetime drift and nested screens surviving logout | Stateful app retains/disposes router; root keys distinguish account and login; navigation/logout regression |
| Kotlin properties before plugins block | Generated Gradle source violates plugins block ordering | Imports retained; executable property initialization after plugins; repeated-config regression |
| Manifest already has queries | Speech service query silently omitted; voice availability varies by build | Merge recognition action into existing XML query; keep PROCESS_TEXT and avoid duplicates |
| Cleanup deletes every tracked file absent from stale manifest | Valid new source/assets/config may be erased | Explicit obsolete phase-instruction list; inventory is validation only; no resetting unknown branch |
| Clean tree exits before pushing local commits | Retry after failed push can leave source unsynchronized | BAT clean path still reaches push; no force push |
| AAB checker hardcoded version code 18 | Next valid release rejected or version drift missed | Compare actual manifest name/code against pubspec; APK/Settings metadata also checked in CI |
| Play build omits Google client ID override | Play OAuth may use different audience than configured pilot | Propagate existing secret into Play defines; no credentials exposed or changed |
| Drive automatic auth client left open | Repeated backups retain transport resources | Close each automatic client in finally; silent authorization and gate preserved |
| Several documents assert incompatible current phases | Historical results confused with final acceptance | One current handoff/canonical/audit/status; prior claims explicitly marked history |
| Duplicate source pointer and generated Python cache | Noise and misleading second source | Redundant `docs/SOURCE_OF_TRUTH.md` removed; old handoff archived; caches ignored |

## Existing behavior preserved

| Area | Current implementation | Boundary |
|---|---|---|
| Identity | Spenva branding, internal finchat package; com.finchat.finchat | Same signing key and Play App Signing OAuth remain necessary |
| Storage | finchat.db, schema 1; shared application handle | No destructive schema migration; restore remains explicit whole-database replacement |
| Capture | Local parser/mappings first; text/voice batches atomic; receipt review | Real speech/OCR quality and permissions require Android |
| Navigation/UI | Current composer, smart date filters, swipe editing/deletion, bundled logo/fonts | Existing physical-device UX preserved; logout lifecycle hardened |
| Reports | Correct periods/totals/pie/daily chart, PDF save/share | No new charts, pricing, quotas or appearance introduced |
| AI | Local factual answers first; pilot Gateway unchanged; Play path fails closed | Deployed availability cannot be proven by mocks or health check |
| Drive | One-time interactive authorization; background path silent | Snapshot acknowledgement/deletion serialization retained |
| Subscription | Free/Plus/Pro/Max; monthly/yearly catalog generation; account-persistent quotas | No server deployment, billing activation or provider spending authorized by this patch |
| Privacy | Explicit local/Drive/server deletion contracts and consent | Real public contact/URLs, Data Safety and lifecycle verification still gates |

## Verification and exact acceptance

Local checks: backend 46 tests, Android generated-template 3 tests, publication validator 5 tests and generated-plan consistency passed. Standalone Dart formatter parsed changed Dart files. CI regression coverage adds UTF-8 restore, invalid duplicate/enum/reference/timestamp snapshots, provider exception safety and logout from nested routes. Historical +18 Play CI success is not reused as proof: the actual canonical head failed one stale payment-contract test. Final source `2f8d47e642c835197ffd9786f0013d12a7f79d5d` passed clean analyze, 141 normal tests (2 skipped), 11 Play-profile tests (1 skipped), 1 native Linux integration, 4 screenshot captures, permanent-key release APK and signed AAB/16KB checks. Exact run/artifact links are in [playstore/VALIDATION.md](playstore/VALIDATION.md). Subsequent documentation-only commits preserve the tested runtime/workflows. PR4 remains unmerged.

Local Flutter execution was blocked by automatic review because initialization attempted metadata-service network access. No local Flutter analyze/test/APK success is claimed. Remote CI is the independent validation route.

Physical Android acceptance: update existing install without uninstall; Google login/restart/logout from Settings/Backup; text and segmented Indonesian speech; camera/file/gallery OCR and cancellation/denied permission; review/edit and category learning; report periods/large nominal/font; PDF save/share; UTF-8 export/restore; Drive silent/manual/automatic/deletion; pilot Gateway refresh; Play-distributed app signing/OAuth; quota and billing lifecycle only once backend/products are activated.

Publication profile still intentionally records missing identity/contact/URLs/Console/closed-test approvals. Wrangler feedback KV is a deployment placeholder. This source audit does not turn a disabled/unconfigured external service into a running production service. Keep checkout and cloud features visibly unavailable where configuration is absent; local core remains usable. Do not claim zero external gates or production-ready.

## Cleanup decisions

Only the redundant source pointer is removed from tracked current source. Brand source vectors, bundled raster images/fonts/licenses, server tests, release validator and historical evidence are retained because they support regeneration or validation. Generated caches are excluded by gitignore. Repository manifest is rebuilt from staged source and tested in CI; it is never a deletion whitelist.

## Source inventory

Inventory records each tracked path and purpose. Inclusion is not a claim that a plugin works on a physical device. File roles are paired with source-level findings and executable tests above.

| Path | Role |
|---|---|
| `.gitattributes` | Project metadata/tooling |
| `.github/workflows/build_android.yml` | CI workflow |
| `.github/workflows/finchat_audit_validation.yml` | CI workflow |
| `.github/workflows/flutter_test.yml` | CI workflow |
| `.github/workflows/play_store.yml` | CI workflow |
| `.github/workflows/release.yml` | CI workflow |
| `.gitignore` | Project metadata/tooling |
| `Ai start here.md` | Product/source documentation |
| `CHANGELOG.md` | Product/source documentation |
| `README.md` | Product/source documentation |
| `UPDATE_GITHUB.bat` | Project metadata/tooling |
| `analysis_options.yaml` | Project metadata/tooling |
| `assets/brand/GOOGLE_ASSET_SOURCE.txt` | Bundled product asset/config/license |
| `assets/brand/android_foreground.png` | Bundled product asset/config/license |
| `assets/brand/android_foreground.svg` | Bundled product asset/config/license |
| `assets/brand/android_icon.png` | Bundled product asset/config/license |
| `assets/brand/android_icon.svg` | Bundled product asset/config/license |
| `assets/brand/google-g.png` | Bundled product asset/config/license |
| `assets/brand/header.png` | Bundled product asset/config/license |
| `assets/brand/header.svg` | Bundled product asset/config/license |
| `assets/brand/mark.png` | Bundled product asset/config/license |
| `assets/brand/mark.svg` | Bundled product asset/config/license |
| `assets/brand/sign_in.png` | Bundled product asset/config/license |
| `assets/brand/sign_in.svg` | Bundled product asset/config/license |
| `assets/config/subscription_plans.json` | Bundled product asset/config/license |
| `assets/fonts/DejaVuSans-Bold.ttf` | Bundled product asset/config/license |
| `assets/fonts/DejaVuSans.ttf` | Bundled product asset/config/license |
| `assets/fonts/GoogleSans-Medium.ttf` | Bundled product asset/config/license |
| `assets/fonts/GoogleSans-OFL.txt` | Bundled product asset/config/license |
| `assets/fonts/LICENSE.txt` | Bundled product asset/config/license |
| `assets/legal/privacy_id.txt` | Bundled product asset/config/license |
| `docs/AI_CONTRACT.md` | Product/source documentation |
| `docs/ARCHITECTURE.md` | Product/source documentation |
| `docs/AUDIT_0.3.2+11.md` | Product/source documentation |
| `docs/AUDIT_0.3.2+12.md` | Product/source documentation |
| `docs/AUDIT_0.3.2+13.md` | Product/source documentation |
| `docs/AUDIT_0.3.2+14.md` | Product/source documentation |
| `docs/AUDIT_0.3.2+15.md` | Product/source documentation |
| `docs/AUDIT_0.3.2+16.md` | Product/source documentation |
| `docs/BUGFIX_0.3.2+6_DATABASE_AI.md` | Product/source documentation |
| `docs/FINCHAT_MASTER_CONTEXT.md` | Product/source documentation |
| `docs/FULL_REPOSITORY_AUDIT.md` | Product/source documentation |
| `docs/GOOGLE_ACCOUNT_AND_DRIVE_SETUP.md` | Product/source documentation |
| `docs/IMPLEMENTATION_STATUS.md` | Product/source documentation |
| `docs/MULTI_USER_AI_AND_MONETIZATION.md` | Product/source documentation |
| `docs/PHASES.md` | Product/source documentation |
| `docs/PHASE_11_12_IMPLEMENTATION_HISTORY.md` | Product/source documentation |
| `docs/PHASE_11_7_E2E_MATRIX.md` | Product/source documentation |
| `docs/PHASE_12_COMPLETION_REPORT.md` | Product/source documentation |
| `docs/PHASE_12_HARDENING_MATRIX.md` | Product/source documentation |
| `docs/PRD.md` | Product/source documentation |
| `docs/ROADMAP_AUDIT.md` | Product/source documentation |
| `docs/SPENVA_CANONICAL_SOURCE.md` | Product/source documentation |
| `docs/UPDATE_RELEASE.md` | Product/source documentation |
| `docs/VOICE_INPUT.md` | Product/source documentation |
| `docs/history/AI_HANDOFF_HISTORY.md` | Product/source documentation |
| `docs/playstore/DATA_SAFETY.md` | Product/source documentation |
| `docs/playstore/LAUNCH.md` | Product/source documentation |
| `docs/playstore/LISTING_ID.md` | Product/source documentation |
| `docs/playstore/PLANS.md` | Product/source documentation |
| `docs/playstore/SUBSCRIPTION.md` | Product/source documentation |
| `docs/playstore/VALIDATION.md` | Product/source documentation |
| `docs/playstore/feature-graphic.png` | Project metadata/tooling |
| `docs/playstore/publication-profile.json` | Project metadata/tooling |
| `docs/playstore/store-icon.png` | Project metadata/tooling |
| `docs/privacy/index.html` | Project metadata/tooling |
| `integration_test/phase_11_end_to_end_test.dart` | Regression/integration coverage |
| `lib/application/ai/ai_secure_config_service.dart` | Application orchestration |
| `lib/application/ai/financial_qa_service.dart` | Application orchestration |
| `lib/application/ai/question_period.dart` | Application orchestration |
| `lib/application/auth/google_auth_service.dart` | Application orchestration |
| `lib/application/auth/google_id_token_session.dart` | Application orchestration |
| `lib/application/auth/google_sign_in_coordinator.dart` | Application orchestration |
| `lib/application/backup/automatic_backup_service.dart` | Application orchestration |
| `lib/application/backup/backup_preference_service.dart` | Application orchestration |
| `lib/application/backup/backup_service.dart` | Application orchestration |
| `lib/application/backup/google_drive_auth_service.dart` | Application orchestration |
| `lib/application/billing/generated_plans.dart` | Application orchestration |
| `lib/application/billing/monetization_config.dart` | Application orchestration |
| `lib/application/billing/payment_gateway.dart` | Application orchestration |
| `lib/application/billing/plan_catalog.dart` | Application orchestration |
| `lib/application/billing/play_billing_service.dart` | Application orchestration |
| `lib/application/billing/quota_service.dart` | Application orchestration |
| `lib/application/billing/subscription_service.dart` | Application orchestration |
| `lib/application/ocr/receipt_ocr_service.dart` | Application orchestration |
| `lib/application/ocr/receipt_transaction_parser.dart` | Application orchestration |
| `lib/application/privacy/account_data_service.dart` | Application orchestration |
| `lib/application/privacy/data_operation_gate.dart` | Application orchestration |
| `lib/application/privacy/drive_data_deletion.dart` | Application orchestration |
| `lib/application/reports/report_pdf_service.dart` | Application orchestration |
| `lib/application/reports/report_service.dart` | Application orchestration |
| `lib/application/session/session_manager.dart` | Application orchestration |
| `lib/application/speech/voice_input_service.dart` | Application orchestration |
| `lib/application/transactions/input_intent.dart` | Application orchestration |
| `lib/application/transactions/local_transaction_parser.dart` | Application orchestration |
| `lib/application/transactions/transaction_intelligence_service.dart` | Application orchestration |
| `lib/application/update/update_service.dart` | Application orchestration |
| `lib/core/constants/app_constants.dart` | Shared core/app bootstrap |
| `lib/core/errors/app_failure.dart` | Shared core/app bootstrap |
| `lib/core/errors/input_failure_message.dart` | Shared core/app bootstrap |
| `lib/core/formatting/rupiah.dart` | Shared core/app bootstrap |
| `lib/core/release/play_release_config.dart` | Shared core/app bootstrap |
| `lib/core/validation/transaction_validator.dart` | Shared core/app bootstrap |
| `lib/data/ai/openai_compatible_ai_provider.dart` | Data/provider implementation |
| `lib/data/backup/google_drive_backup_provider.dart` | Data/provider implementation |
| `lib/data/local/database_schema.dart` | Data/provider implementation |
| `lib/data/local/finchat_database.dart` | Data/provider implementation |
| `lib/data/ocr/image_receipt_preprocessor.dart` | Data/provider implementation |
| `lib/data/ocr/mlkit_receipt_ocr_provider.dart` | Data/provider implementation |
| `lib/data/repositories/in_memory_session_repository.dart` | Data/provider implementation |
| `lib/data/repositories/sqlite_category_repository.dart` | Data/provider implementation |
| `lib/data/repositories/sqlite_transaction_repository.dart` | Data/provider implementation |
| `lib/data/session/secure_session_repository.dart` | Data/provider implementation |
| `lib/data/speech/speech_to_text_provider.dart` | Data/provider implementation |
| `lib/data/update/github_release_update_provider.dart` | Data/provider implementation |
| `lib/domain/ai/ai_category_fallback.dart` | Domain contract/model |
| `lib/domain/ai/financial_ai_provider.dart` | Domain contract/model |
| `lib/domain/auth/google_auth_result.dart` | Domain contract/model |
| `lib/domain/backup/backup_models.dart` | Domain contract/model |
| `lib/domain/billing/subscription_models.dart` | Domain contract/model |
| `lib/domain/entities/category_entity.dart` | Domain contract/model |
| `lib/domain/entities/category_mapping.dart` | Domain contract/model |
| `lib/domain/entities/session.dart` | Domain contract/model |
| `lib/domain/entities/transaction_entity.dart` | Domain contract/model |
| `lib/domain/ocr/receipt_image_preprocessor.dart` | Domain contract/model |
| `lib/domain/ocr/receipt_ocr.dart` | Domain contract/model |
| `lib/domain/parsing/money_amount_parser.dart` | Domain contract/model |
| `lib/domain/parsing/spoken_money_normalizer.dart` | Domain contract/model |
| `lib/domain/parsing/voice_transaction_normalizer.dart` | Domain contract/model |
| `lib/domain/reports/daily_expenses.dart` | Domain contract/model |
| `lib/domain/reports/report_insights.dart` | Domain contract/model |
| `lib/domain/reports/report_models.dart` | Domain contract/model |
| `lib/domain/reports/selected_period.dart` | Domain contract/model |
| `lib/domain/repositories/category_repository.dart` | Domain contract/model |
| `lib/domain/repositories/session_repository.dart` | Domain contract/model |
| `lib/domain/repositories/transaction_repository.dart` | Domain contract/model |
| `lib/domain/services/category_learning_service.dart` | Domain contract/model |
| `lib/domain/speech/speech_recognition.dart` | Domain contract/model |
| `lib/domain/speech/transcript_buffer.dart` | Domain contract/model |
| `lib/domain/update/app_update.dart` | Domain contract/model |
| `lib/main.dart` | Shared core/app bootstrap |
| `lib/presentation/navigation/app_router.dart` | Presentation |
| `lib/presentation/screens/backup_screen.dart` | Presentation |
| `lib/presentation/screens/chat_screen.dart` | Presentation |
| `lib/presentation/screens/financial_qa_screen.dart` | Presentation |
| `lib/presentation/screens/login_screen.dart` | Presentation |
| `lib/presentation/screens/privacy_screen.dart` | Presentation |
| `lib/presentation/screens/receipt_review_screen.dart` | Presentation |
| `lib/presentation/screens/report_screen.dart` | Presentation |
| `lib/presentation/screens/settings_screen.dart` | Presentation |
| `lib/presentation/screens/splash_screen.dart` | Presentation |
| `lib/presentation/screens/subscription_screen.dart` | Presentation |
| `lib/presentation/widgets/period_filter.dart` | Presentation |
| `lib/presentation/widgets/spenva_brand.dart` | Presentation |
| `pubspec.yaml` | Project metadata/tooling |
| `server/play-billing/README.md` | Product/source documentation |
| `server/play-billing/meter.mjs` | Subscription server contract/test/config |
| `server/play-billing/meter.test.mjs` | Subscription server contract/test/config |
| `server/play-billing/package.json` | Subscription server contract/test/config |
| `server/play-billing/plans.generated.mjs` | Subscription server contract/test/config |
| `server/play-billing/worker.mjs` | Subscription server contract/test/config |
| `server/play-billing/worker.test.mjs` | Subscription server contract/test/config |
| `server/play-billing/wrangler.jsonc` | Subscription server contract/test/config |
| `test/application/automatic_backup_service_test.dart` | Regression/integration coverage |
| `test/application/backup_audit_regression_test.dart` | Regression/integration coverage |
| `test/application/backup_preference_service_test.dart` | Regression/integration coverage |
| `test/application/backup_service_test.dart` | Regression/integration coverage |
| `test/application/backup_snapshot_validation_test.dart` | Regression/integration coverage |
| `test/application/cloud_acknowledgement_test.dart` | Regression/integration coverage |
| `test/application/drive_silent_auth_test.dart` | Regression/integration coverage |
| `test/application/financial_qa_service_test.dart` | Regression/integration coverage |
| `test/application/google_id_token_session_test.dart` | Regression/integration coverage |
| `test/application/input_intent_test.dart` | Regression/integration coverage |
| `test/application/ocr/receipt_ocr_service_test.dart` | Regression/integration coverage |
| `test/application/ocr/receipt_transaction_parser_test.dart` | Regression/integration coverage |
| `test/application/question_period_test.dart` | Regression/integration coverage |
| `test/application/report_pdf_service_test.dart` | Regression/integration coverage |
| `test/application/report_service_test.dart` | Regression/integration coverage |
| `test/application/session_manager_google_test.dart` | Regression/integration coverage |
| `test/application/session_manager_test.dart` | Regression/integration coverage |
| `test/application/speech/voice_input_service_test.dart` | Regression/integration coverage |
| `test/application/transaction_entry_flow_test.dart` | Regression/integration coverage |
| `test/application/transaction_intelligence_service_test.dart` | Regression/integration coverage |
| `test/application/transactions/local_transaction_parser_test.dart` | Regression/integration coverage |
| `test/chat_composer_timeline_test.dart` | Regression/integration coverage |
| `test/core/input_failure_message_test.dart` | Regression/integration coverage |
| `test/core/transaction_validator_test.dart` | Regression/integration coverage |
| `test/daily_input_reset_test.dart` | Regression/integration coverage |
| `test/data/gateway_contract_test.dart` | Regression/integration coverage |
| `test/data/openai_compatible_ai_provider_test.dart` | Regression/integration coverage |
| `test/data/openai_phase12_hardening_test.dart` | Regression/integration coverage |
| `test/data/sqlite_transaction_repository_phase12_test.dart` | Regression/integration coverage |
| `test/data_database_test.dart` | Regression/integration coverage |
| `test/domain/ai_category_fallback_test.dart` | Regression/integration coverage |
| `test/domain/backup_models_test.dart` | Regression/integration coverage |
| `test/domain/billing_subscription_models_test.dart` | Regression/integration coverage |
| `test/domain/daily_expenses_test.dart` | Regression/integration coverage |
| `test/domain/ocr/receipt_image_preprocessor_test.dart` | Regression/integration coverage |
| `test/domain/parsing/money_amount_parser_test.dart` | Regression/integration coverage |
| `test/domain/report_insights_test.dart` | Regression/integration coverage |
| `test/domain/selected_period_test.dart` | Regression/integration coverage |
| `test/domain/speech/speech_recognition_test.dart` | Regression/integration coverage |
| `test/domain/spoken_money_test.dart` | Regression/integration coverage |
| `test/domain/update_service_test.dart` | Regression/integration coverage |
| `test/navigation_back_test.dart` | Regression/integration coverage |
| `test/period_calendar_test.dart` | Regression/integration coverage |
| `test/play_release_test.dart` | Regression/integration coverage |
| `test/play_store_screenshots_test.dart` | Regression/integration coverage |
| `test/spenva_device_regression_test.dart` | Regression/integration coverage |
| `test/subscription_quota_test.dart` | Regression/integration coverage |
| `test/widget_test.dart` | Regression/integration coverage |
| `tooling/android/configure_android_ci.py` | Android/build/release tooling |
| `tooling/android/proguard-rules.pro` | Android/build/release tooling |
| `tooling/android/test_configure_android_ci.py` | Android/build/release tooling |
| `tooling/check_repository.py` | Android/build/release tooling |
| `tooling/play/check_bundle.py` | Android/build/release tooling |
| `tooling/play/configure_play.py` | Android/build/release tooling |
| `tooling/play/generate_subscription.py` | Android/build/release tooling |
| `tooling/play/render_legal.py` | Android/build/release tooling |
| `tooling/play/test_check_bundle.py` | Android/build/release tooling |
| `tooling/play/write_profile.py` | Android/build/release tooling |
| `tooling/repository_manifest.txt` | Android/build/release tooling |
