> Current source status: **0.3.4+19**, 9 October 2026 UTC. See [SPENVA_CANONICAL_SOURCE.md](SPENVA_CANONICAL_SOURCE.md) and the current detailed audit. Older version/build statements below are historical evidence and do not verify this patch.

## Verified GitHub CI — 0.3.2+14 (5 Oktober 2026)

- Runtime/test commit `f36a3c11f0bd581e0a4d50f4d9d5d1b20959aa86`, branch `codex/finchat-input-navigation-audit`. Dokumen verifikasi sesudah commit ini tidak mengubah runtime.
- Audit https://github.com/rama160/Finchat/actions/runs/37329235611 dan workflow Flutter asli https://github.com/rama160/Finchat/actions/runs/37329255297 berhasil: Flutter 3.47.6, analyze No issues found, **111 tests passed** pada kedua workflow.
- Signed release APK **92.3 MB**, menggunakan permanent FinChat release keystore: https://github.com/rama160/Finchat/actions/runs/37329235611/artifacts/11353523044 . Versi pubspec dan Pengaturan sama-sama `0.3.2+14`.
- ZIP artifact SHA-256 `c8a394280e1099888345c81a26f3dcdc4803e2387d11f96a69ca6d50f1b2a224`; ini hash arsip artifact, bukan hash APK di dalamnya.
- Regresi: fokus/keyboard/posisi composer, draft berikutnya, timeline campuran, kalender hari/rentang/bulan/tahun termasuk mempertahankan filter saat dibuka kembali, periode pertanyaan, insight/ringkasan grafik, suara multi transaksi tanpa AI, serta batch kategori struk sekali baca.
- Manifest uploader mencakup seluruh 153 file tracked termasuk helper, test dan workflow audit baru. Tiga workflow asli, schema/lifecycle database, repository transaksi, money parser dan OAuth/secrets dipertahankan. Main tetap `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`.
- Gateway 0.1.1 sudah diverifikasi terpisah HTTP200/622 ms: https://github.com/rama160/AI-Gateway/actions/runs/37316536289 . Catatan lama HTTP403/belum deploy di bawah adalah riwayat, bukan status terkini.
- **Uji HP masih diperlukan:** IME asli saat kirim, microphone multi transaksi, kamera/attach OCR dan pengukuran latency struk. Tes batch membuktikan satu pembacaan pemetaan kategori, bukan peningkatan waktu OCR pada perangkat.
- Bagian ini menggantikan status verifikasi tertunda dan hasil versi lama di bawah.

# Audit device UX — 0.3.2+14

## Device UX follow-up — 0.3.2+14 (5 Oktober 2026)

- Chat: transaksi dan Q&A tersusun berdasarkan waktu dalam satu timeline; pesan baru muncul paling bawah. Input dan status memiliki tinggi tetap, fokus/keyboard dipertahankan saat kirim, dan draft berikutnya tidak dikosongkan setelah proses sebelumnya selesai.
- Halaman Input tidak memiliki filter tanggal. Periode pertanyaan dibaca dari teks (hari/rentang/bulan/tahun); tanpa periode eksplisit, pertanyaan memakai seluruh riwayat. Daftar transaksi harian tetap reset tampilan saat berganti hari tanpa menghapus database.
- Header filter Laporan tetap sama; klik langsung membuka kalender Minggu–Sabtu dengan pilihan tanggal, rentang, bulan dan tahun. Satu bulan/tahun lengkap dikenali otomatis.
- Keterangan grafik berada di bawah grafik dan merangkum data, bukan fungsi. Total, pie, PDF dan insight tetap mengikuti periode; grafik satu hari tetap membandingkan dengan hari sebelumnya.
- Insight: arus kas, rata-rata belanja termasuk hari nol, puncak belanja, perubahan harian dan transaksi berulang/ukuran transaksi. Tidak menyimpulkan kondisi pendapatan keseluruhan saat pemasukan belum tercatat.
- Suara: sesi dictation, nominal kata/angka dan harga tanpa pemisah diproses lokal sebagai multi transaksi. Batas durasi/pause tetap dapat dibatasi Android; kualitas mic harus diuji di HP.
- Struk: satu batch category learning, tanpa parse ulang tiap produk, recognizer dipakai ulang selama layar hidup; resize kamera mengikuti batas OCR dan file sementara tidak memakai fsync. Review dan koreksi kategori tetap wajib. Tidak ada klaim pengurangan latency HP sebelum pengukuran perangkat.
- Schema, lifecycle database, money parser, transaction repository, OAuth/secrets, endpoint Gateway dan workflow asli dipertahankan.
- Status verifikasi patch ini: analyze bersih, 111 tes lulus dan signed APK berhasil; bukti final ada di atas. Tes regresi mencakup keyboard/fokus/posisi input, draft berikutnya, urutan chat, kalender, scope pertanyaan, insight, multi suara dan batch struk.
- Gateway terpisah telah diperbarui ke 0.1.1 dan live provider berhasil HTTP200/622 ms, endpoint probe dihapus. Bukti https://github.com/rama160/AI-Gateway/actions/runs/37316536289 . Catatan lama “belum deploy/HTTP403” di bawah adalah riwayat dan sudah digantikan hasil Gateway terbaru.

## Penerimaan perangkat

Uji posisi keyboard saat tombol Kirim maupun tombol send ditekan, urutan transaksi–pertanyaan–transaksi, kalender rentang 6–7 Oktober serta sebulan/setahun, suara “nasi sepuluh ribu dan bensin lima puluh ribu lalu parkir dua ribu”, dan waktu struk dari kamera/attach hingga review. CI bukan bukti kualitas pengenalan suara/foto di Android.
