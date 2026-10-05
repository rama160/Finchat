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

# FinChat Architecture

## Current patch — 0.3.2+11 (2026-10-05)

Authoritative current audit: `AUDIT_0.3.2+11.md`. Fixes RouterDelegate navigatorKey/system Back, CI FFI factory setup, integrated local/AI questions, money-in-question routing, guarded camera/file pickers, voice cancel callbacks, Google Drive snapshot acknowledgements, bottom navigation reports and shared smart period filter. Transaction cards use gestures only; white rounded composer includes emoji/attachment/camera/mic/send.

SQLite schema and existing workflows unchanged. Source is matched to main commit `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Flutter SDK unavailable locally; CI and real Android device acceptance are required. Baseline CI had 72 passed / 1 failed (global FFI factory test setup); do not describe the baseline result as verification of this patch.


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

## Runtime lifecycle hardening — 0.3.2+6

Production screens use the shared default `FinChatDatabase()` instance. Individual screen `dispose()` methods may still call `close()` for lifecycle compatibility, but the shared production instance does not close from a screen. Isolated database instances remain available for tests and custom tooling. Database opens are serialized to prevent duplicate concurrent handles.

## AI Gateway runtime

`OpenAiCompatibleAiProvider` uses the existing `GoogleSignInCoordinator` to obtain the logged-in Google ID token and sends it to the Cloudflare Gateway over HTTPS. The normal production provider does not depend on the legacy local `ai.enabled` flag. Gemini credentials remain server-side.
