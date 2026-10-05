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
- Status: patch disiapkan; CI terbaru harus diverifikasi. OCR native dan AI live perlu tes perangkat. Screenshot stack trace terobfuscate tidak cukup untuk memastikan akar NPE; keep rules adalah mitigasi release, bukan klaim hasil perangkat.

## Verification

Regression tests: spoken numeric and word amounts; offline multi-item capture with zero provider calls; filtered nota excludes nonmatching rows; basic saving advice remains local; daily expense zero buckets/income exclusion/total reconciliation; widget navigation retains Back behavior, speech-form entry, chart replacement. Existing test suite remains enabled.

Real device acceptance: update signed APK over installed version; capture same receipt from camera and attach; confirm review opens without native NPE; enter "nasi 10 ribu" and voice "nasi sepuluh ribu" offline; multi-item save does not wait on network; log in Google and ask unsupported/local-impossible question; verify Gateway answer; repeat after app restart/token expiry; midnight/resume preserves history but resets view; change report day/range/full month and reconcile total with daily bars; swipe edit/delete and cloud acknowledgements still work.

The native screenshot only includes obfuscated stack frames. Diagnosis is incomplete without release retrace/logcat; broad but OCR-specific keep rules protect reflective ML Kit/component initialization. If device failure persists, collect logcat with full exception beginning, release mapping, device/API and receipt sample. CI verifies compilation, not successful physical-camera/model execution.

Nota currently returned as local text with matching rows and total; existing PDF export from Reports remains available. No new automated file export from a chat question is claimed.
