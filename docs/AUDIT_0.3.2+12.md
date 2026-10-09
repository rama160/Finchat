> Current source status: **0.3.4+19**, 9 October 2026 UTC. See [SPENVA_CANONICAL_SOURCE.md](SPENVA_CANONICAL_SOURCE.md) and the current detailed audit. Older version/build statements below are historical evidence and do not verify this patch.

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

# Audit device follow-up FinChat 0.3.2+12

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

## Verification

Regression tests: spoken numeric and word amounts; offline multi-item capture with zero provider calls; filtered nota excludes nonmatching rows; basic saving advice remains local; daily expense zero buckets/income exclusion/total reconciliation; widget navigation retains Back behavior, speech-form entry, chart replacement. Existing test suite remains enabled.

Real device acceptance: update signed APK over installed version; capture same receipt from camera and attach; confirm review opens without native NPE; enter "nasi 10 ribu" and voice "nasi sepuluh ribu" offline; multi-item save does not wait on network; log in Google and ask unsupported/local-impossible question; verify Gateway answer; repeat after app restart/token expiry; midnight/resume preserves history but resets view; change report day/range/full month and reconcile total with daily bars; swipe edit/delete and cloud acknowledgements still work.

The native screenshot only includes obfuscated stack frames. Diagnosis is incomplete without release retrace/logcat; broad but OCR-specific keep rules protect reflective ML Kit/component initialization. If device failure persists, collect logcat with full exception beginning, release mapping, device/API and receipt sample. CI verifies compilation, not successful physical-camera/model execution.

Nota currently returned as local text with matching rows and total; existing PDF export from Reports remains available. No new automated file export from a chat question is claimed.
