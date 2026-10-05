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
