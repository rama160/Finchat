# FinChat

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


FinChat adalah aplikasi Android personal finance assistant berbasis Flutter dengan pendekatan **offline-first** dan chat-first.

## Current status

- Phase 1–9 technical baselines: completed.
- Phase 9 GitHub Actions: reported successful by project owner.
- Phase 10: Update & Release + documentation reconciliation.
- Phase 11: QA & end-to-end integration — next after Phase 10 CI passes.

See `docs/ROADMAP_AUDIT.md` for the distinction between technical baselines and remaining product requirements.

## Development model

Repository ini dirancang agar pengguna tidak perlu memasang Flutter secara lokal. GitHub Actions adalah environment verifikasi utama:

1. Push kode ke GitHub.
2. Actions memasang Flutter stable.
3. Actions menjalankan `flutter pub get`, `flutter analyze`, dan `flutter test`.
4. Workflow Android membuat folder `android/` jika belum ada.
5. Actions menjalankan `flutter build apk --release`.
6. APK tersedia sebagai artifact/release asset.

## Upload otomatis dari Windows

Jalankan `UPDATE_GITHUB.bat` dari root project. Script menyinkronkan file baru/perubahan/penghapusan dengan `git add -A`, tidak melakukan force push, dan berhenti bila merge conflict perlu keputusan manual.

## Update aplikasi

Settings memiliki update checker yang membaca latest published GitHub Release dari repository `rama160/Finchat`. Jika versi remote lebih tinggi, pengguna dapat membuka halaman release untuk mengunduh APK. Self-install/Play Store distribution belum dianggap selesai dan dicatat di roadmap.

## Data architecture

SQLite adalah local source of truth. Transaksi diakses melalui repository. Category corrections disimpan per user dan dicatat dalam history. AI/OCR tidak boleh menulis database secara langsung.

## Dokumen utama

1. `Ai start here.md`
2. `docs/FINCHAT_MASTER_CONTEXT.md`
3. `docs/PRD.md`
4. `docs/ARCHITECTURE.md`
5. `docs/PHASES.md`
6. `docs/AI_CONTRACT.md`
7. `docs/ROADMAP_AUDIT.md`
8. `docs/IMPLEMENTATION_STATUS.md`
9. `CHANGELOG.md`


### Android CI build note
The GitHub workflow supports both legacy Groovy (`build.gradle`) and modern Kotlin (`build.gradle.kts`) Android templates when applying ML Kit R8 rules.


### Current Phase 11.2 progress
Receipt/OCR integration is in progress. Camera/gallery input, existing OCR preprocessing + ML Kit, receipt line-item parsing, review/edit, category learning, and SQLite persistence are connected. Full CI and device verification are still required before marking the slice complete.


### Phase 11.4
Reports/PDF now includes summary metrics, category distribution, transaction count, insight, drill-down, empty/loading/error states, and category details in exported PDF.

### Phase 11.5
Backup lokal JSON, restore dengan konfirmasi, Google Sign-In + Google Drive appDataFolder, status/error UX, dan preferensi backup otomatis sudah diintegrasikan. OAuth device verification ditunda ke Phase 11.7.

### Phase 11.6
Added a concrete OpenAI-compatible AI adapter behind the existing category fallback contract, secure API configuration, offline-safe fallback behavior, and a financial Q&A screen based on app-computed report data.

### Phase 11.7
Added the final Phase 11 E2E QA matrix, integration-test shell, and Windows QA runner. Device verification remains pending and is intentionally scheduled after Phase 12 hardening.


## Phase 12
Phase 12.1–12.8 production hardening is included in the latest cumulative package. Run GitHub Actions analyze/test/release before device acceptance.

## Multi-user account foundation
Google Sign-In is integrated into the session layer. Existing email login remains only as a local/testing fallback so existing local data is not stranded. Real Google OAuth device verification requires the app's own OAuth configuration and SHA-1 credentials.

## Monetization foundation (OFF)
Four subscription tiers are modeled: Free, Basic, Pro, Unlimited. Payment methods are modeled for QRIS, GoPay, bank transfer, card and other e-wallets. Subscription and payment flags are disabled during pilot testing; no payment is collected. Production billing must be enforced by a backend and verified entitlement/webhook flow.

## Runtime bugfix package 0.3.2+6

The 2026-09-29 repository audit was followed by the 2026-10-05 runtime bugfix package. The bugfix addresses the shared SQLite `database_closed` failure affecting text/voice/receipt capture and restores the production Cloudflare Gateway AI path. See `docs/BUGFIX_0.3.2+6_DATABASE_AI.md` and `docs/FULL_REPOSITORY_AUDIT.md`. Use `UPDATE_GITHUB.bat` as the single Windows synchronizer; it stages additions, updates and tracked deletions with `git add -A` and never force-pushes.
