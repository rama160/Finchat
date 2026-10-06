## Verified GitHub CI — Spenva 0.3.2+16 (6 Oktober 2026)

- Kode/aset teruji pada commit `b85997e29533040e483036cabf3153dca6a8a548`, branch `codex/finchat-input-navigation-audit`. Commit dokumentasi setelahnya tidak mengubah runtime/aset.
- Flutter 3.47.6; analyze **No issues found** dan **120 tests passed** pada kedua workflow: https://github.com/rama160/Finchat/actions/runs/37410578014 dan https://github.com/rama160/Finchat/actions/runs/37410573458 .
- Signed release APK **92.8MB**, version APK/Pengaturan `0.3.2+16`, launcher Spenva: https://github.com/rama160/Finchat/actions/runs/37410573458/artifacts/11389451246 .
- Permanent FinChat keystore; SHA-1 sertifikat `CA:AA:59:2F:EC:CA:7C:8B:8B:16:C0:83:30:7D:43:A3:25:76:2E:10`, sama dengan APK +15. Pasang sebagai pembaruan tanpa uninstall/hapus data.
- ZIP artifact SHA-256 `c817655ea2d9797df8cc1bacc979d3f7d5a3f9097de0ca39f5a3503d9460245f`; ukuran ZIP 42834013 bytes. Ini hash arsip artifact, bukan hash APK di dalamnya.
- Regresi baru: kategori gaji yang hilang setelah restore ditambahkan tanpa mengganti kategori/mapping pengguna; gaji 5000000 tersimpan sebagai income; nominal 100/160000/567765/100000000 dan Rp .567.678; Input kosong tanpa Halo; composing range tetap ada tanpa underline; pertanyaan tanpa Semua tanggal; kartu full-width dengan jutaan/teks besar; Saldo; PDF dari ikon download tetap simpan/bagikan.
- Logo mark/header/sign in/Android terpisah mengikuti outline bentuk dan wordmark referensi. Foreground adaptive memakai aset monogram yang sama dengan referensi ikon. Semua aset/font tetap dibundel/offline.
- Manifest cocok dengan **173 file** remote. Tiga workflow asli, UPDATE_GITHUB.bat, database/schema/lifecycle, repository transaksi, MoneyAmountParser, autentikasi Google, gateway dan format backup byte-identical terhadap +15. Main tetap `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`.
- Source ZIP: https://github.com/rama160/Finchat/archive/refs/heads/codex/finchat-input-navigation-audit.zip . PR: https://github.com/rama160/Finchat/pull/1 .
- GitHub membuktikan tes dan build, bukan pengujian perangkat fisik. Uji ulang logo/layout, IME asli dan pemasukan setelah restore di HP dengan APK +16. Header ini menggantikan status pending pada catatan implementasi +16.

## Spenva 0.3.2+16 — perbaikan hasil uji HP (6 Oktober 2026)

- Perbaikan formatter digit: tidak lagi menyisipkan titik di awal angka 3/6/9 digit. Semua tampilan, jawaban AI/lokal dan PDF memakai `Rp 567.765`; jawaban provider seperti `Rp .567.678` dinormalisasi.
- Logo mark/header/sign in/launcher menggunakan outline bentuk dan wordmark dari referensi pengguna; tidak menggunakan font pengganti atau gambar pratinjau penuh. Aset terpisah dibundel offline, termasuk foreground adaptive Android.
- Input kosong benar-benar kosong (tanpa ikon dompet, Halo/email atau petunjuk lama). Header sapaan lokal tetap. Composer tidak menggambar underline composing IME, tetap menjaga range/fokus/keyboard; koreksi otomatis/saran/ejaan dimatikan pada kotak input.
- Kartu pemasukan/pengeluaran memakai lebar penuh dan tinggi mengikuti isi, tanpa ellipsis. Selisih periode menjadi Saldo. Tombol Ekspor PDF bawah dihapus; ikon download atas tetap membuka simpan ke perangkat/bagikan PDF.
- Pertanyaan tanpa periode eksplisit langsung dijawab tanpa awalan Semua tanggal. Tanggal/rentang eksplisit tetap dipakai untuk data dan label jawaban.
- Kategori standar memakai nama umum (Makanan dan minuman, Tagihan, Kesehatan, Transportasi, Kebutuhan rumah tangga, Hiburan, Lainnya); ID dan data lama tidak diubah. Kategori impor per-item disembunyikan dari pilihan, kategori buatan pengguna dan pembelajaran tetap dipertahankan.
- Setelah restore parsial, repository kategori menambahkan standar yang hilang dengan insert-ignore tanpa mengganti data/kategori yang sudah ada. Ini menutup kegagalan foreign-key saat gaji pertama setelah backup yang tidak memuat kategori gaji. Input gaji/upah tetap pemasukan; nominal gaji tanpa Rp seperti `gaji 5000000` kini diproses lokal.
- Application ID, database/schema, autentikasi, gateway, format backup, MoneyAmountParser, repository transaksi dan tiga workflow asli dipertahankan. Versi APK/Pengaturan 0.3.2+16.
- Verifikasi GitHub analyze/test/build berhasil: 120 tes lulus dan APK signed 92.8MB (lihat bukti di atas). Pengujian IME/mikrofon dan pemasangan APK masih perlu di HP.
