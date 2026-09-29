# FinChat

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

## Repository audit package 0.3.2+5

The 2026-09-29 full repository audit reconciles the cumulative Phase 12 source with the original FinChat PRD. See `docs/FULL_REPOSITORY_AUDIT.md` for the complete file-by-file review and remaining acceptance gates. Use `UPDATE_GITHUB.bat` as the single Windows synchronizer; it stages additions, updates and tracked deletions with `git add -A` and never force-pushes.
