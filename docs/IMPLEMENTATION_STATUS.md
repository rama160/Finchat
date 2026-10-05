## Follow-up regression coverage

- Android stopped/notListening status no longer submits an unfinished voice transcript; final nominal is required. Regression tests reproduce partial "nasi" arriving before final "nasi 10 ribu".
- Google ID-token session tests cover cached-login reuse, expiry/malformed tokens, single restoration for concurrent calls, sign-out and late restoration rejection. Cache remains in memory and no Google token is written to documentation/storage/logs.
- New widget regression verifies next-day resume hides previous-day items without deleting SQLite history.
- Initial device-patch CI: analyze passed, 86 passed/1 failed (word-number hundred arithmetic); corrected and re-run. Final results must be checked below.

## Device follow-up — 0.3.2+12 (5 Oktober 2026)

- Capture teks/suara/struk kini menggunakan parser dan mapping lokal tanpa HTTP AI per item; mapping dibaca sekali per input. AI Q&A tetap tersedia sebagai fallback.
- Normalisasi nominal suara mendukung "nasi sepuluh ribu" serta "nasi 10 ribu".
- Provider AI menggunakan akun Google hasil authenticate yang diingat coordinator sebelum mencoba restorasi lightweight; JWT kedaluwarsa tidak digunakan dan cache dibersihkan saat sign-out.
- Pertanyaan nota dengan kata kunci menghitung dan merinci hanya deskripsi yang cocok; saran hemat dasar dapat dijawab lokal. Kendala yang belum didukung tidak diam-diam dijawab sebagai total keseluruhan.
- Input default hari ini; midnight/resume mengatur ulang tampilan harian dan Q&A tanpa menghapus data SQLite. Pertanyaan dan jawaban memakai bubble terpisah.
- Laporan mempertahankan total berdasarkan periode dan pie chart; bagian jumlah/detail transaksi di bawah chart diganti grafik pengeluaran harian. Hari tanpa pengeluaran bernilai nol; rentang/bulan mengikuti filter.
- Preprocessing gambar dipindahkan ke isolate. Error OCR tidak menampilkan stack trace di layar; cleanup recognizer tidak menimpa hasil. Keep rules native ML Kit/component registrar diperkuat untuk release.
- Tidak ada perubahan schema, database lifecycle, Drive backup, endpoint Gateway, secrets, atau tiga workflow asli. Perubahan login terbatas pada penyimpanan akun aktif, bukan alur pemilihan akun.
- Status: patch disiapkan; CI terbaru harus diverifikasi. OCR native dan AI live perlu tes perangkat. Screenshot stack trace terobfuscate tidak cukup untuk memastikan akar NPE; keep rules adalah mitigasi release, bukan klaim hasil perangkat.

### Phase 11.1.2 CI fix — file_picker 13 API

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

`ChatScreen` now uses the `file_picker` 13 API (`FilePicker.pickFiles()` and `PlatformFile.readAsBytes()`) instead of the removed `FilePicker.platform`/`withData` pattern. Attachment receipt behavior is unchanged.

# FinChat Implementation Status

**Version:** 0.3.2+6  
**Status date:** 2026-10-05  
**Current stage:** Post-Phase-12 runtime bugfix; fresh CI + real-device acceptance pending.


## Runtime bugfix 0.3.2+6

- Fixed the shared SQLite lifecycle issue behind `DatabaseException(error database_closed)` during text, voice and receipt capture by making the default production database instance application-shared and preventing screen `dispose()` from closing it.
- Added serialized database opening and stale-handle recovery without changing schema or restore/migration behavior.
- Fixed Gateway AI availability by removing the legacy local `ai.enabled` prerequisite from the normal production provider path.
- AI now reuses the existing `GoogleSignInCoordinator` to obtain the current Google ID token before calling the existing Cloudflare Gateway.
- Gemini credentials remain server-side.

## Verified historical baseline

The project owner reported successful GitHub Actions for the earlier cumulative Phase 12 package. That historical result does not automatically verify this audit package because source, workflows, documentation and version metadata changed.

## Implemented product paths

- Persistent secure session with local email test mode and Google Sign-In integration.
- Text and voice transaction capture through local parser/category learning, immediate SQLite persistence, Edit/Delete actions and swipe gestures.
- Indonesian amount shorthand parsing and multi-transaction extraction.
- Camera/gallery receipt OCR with image preprocessing, multi-item extraction, review/edit and SQLite persistence.
- Explicit image-file receipt attachment (JPG/JPEG/PNG/WEBP) added by the repository audit.
- Daily/range/month reports, income/expense totals, balance, transaction grouping, insight, category pie chart, per-category transaction counts, drill-down and PDF sharing.
- Local-first financial Q&A for common totals/saldo/count/top-category questions, with OpenAI-compatible AI only for questions not resolved locally.
- Versioned local backup/restore, Google Drive appDataFolder backup/restore and automatic backup after one-time Drive authorization.
- Secure AI configuration, HTTPS/network hardening and provider contract.
- GitHub Releases update checker and release workflow.
- Free/Basic/Pro/Unlimited monetization domain foundation remains disabled during pilot.

## Repository cleanup in 0.3.2+5

- Removed `.git` from the distributable ZIP.
- Consolidated seven root phase copy-instruction files into `docs/PHASE_11_12_IMPLEMENTATION_HISTORY.md`.
- Replaced multiple GitHub/QA BAT files with one `UPDATE_GITHUB.bat` for additions, updates and deletions.
- Consolidated duplicated Android CI mutation logic into `tooling/android/configure_android_ci.py`; build and release workflows now use the same R8/minSdk/permission settings.
- Added `docs/FULL_REPOSITORY_AUDIT.md` as the authoritative file-by-file audit and acceptance matrix.

## Remaining verification gates

### GitHub Actions — required for this exact package
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --release`

### Real Android device — still required
- Google Sign-In and persistent session.
- Voice microphone permission, Indonesian recognition and multi-transaction save.
- Camera and explicit image-file receipt attachment.
- OCR on clear, blurred and multi-item receipts.
- Edit/Delete buttons and swipe gestures.
- Report pie chart, category counts, income/expense drill-down and PDF sharing.
- Local backup export/import.
- Google Drive authorization, manual backup/restore and automatic backup.
- Financial questions entered directly in the main chat composer.
- Update checker against an actual published GitHub Release.

No destructive SQLite schema migration is introduced by the 0.3.2+5 audit package or the 0.3.2+6 runtime bugfix.

### 0.3.2+9 analyzer follow-up
The CI analyzer reported two remaining errors in `openai_compatible_ai_provider.dart`. The constructor now uses an initializing formal for `_idTokenProvider`, and token-provider invocation uses explicit nullable-flow promotion. No existing workflow or business logic was changed.

### 0.3.2+10 database test follow-up
- Fixed `FinChatDatabase` production singleton initialization order for `sqflite_common_ffi` tests.
- The shared production instance is now created lazily, after the test suite can initialize `databaseFactoryFfi`.
- Preserved shared production connection and screen-level `close()` protection.
- No SQLite schema or application business logic changed.
- CI verification pending.
