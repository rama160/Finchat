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

## Verified GitHub CI — Spenva 0.3.2+15 (6 Oktober 2026)

- Runtime/test commit `0b9d9b0ca738f4c28a3847581920c07b9d08c933`, branch `codex/finchat-input-navigation-audit`. Dokumen final sesudah commit ini tidak mengubah kode/aset yang diuji.
- Flutter 3.47.6, analyze No issues found, **119 tests passed** pada kedua workflow: https://github.com/rama160/Finchat/actions/runs/37401893802 dan https://github.com/rama160/Finchat/actions/runs/37401889047 .
- Signed release APK **92.6MB**, permanent FinChat release keystore, label launcher Spenva, versi aplikasi/Pengaturan `0.3.2+15`: https://github.com/rama160/Finchat/actions/runs/37401889047/artifacts/11385802047 .
- Hash SHA-256 ZIP artifact `fd700715fc5794c9b803eaef53a1e2ad7c1a30a048916c2c38e43e7254ab16b8`; ini hash arsip artifact, bukan hash APK di dalamnya.
- Regresi: composer 360 px/teks 1,6× dengan keyboard, fokus/rect/draft yang stabil saat kirim; timeline campuran; SQLite gaji 5 juta; dua transaksi suara pada callback frasa/cumulative/final; Drive authorization `promptIfUnauthorized=false` dan 0 authenticate/lightweight calls; sign in 320 px/teks 1,8×; nominal jutaan dan simpan/bagikan PDF.
- Semua aset/logo, subset font Latin/simbol DejaVu beserta lisensi, dekorasi dan animasi singkat native Flutter dibundel. Tidak memakai gambar pratinjau sebagai halaman aplikasi atau aset/font yang diambil dari internet saat berjalan.
- Main tetap `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Tiga workflow asli, UPDATE_GITHUB.bat, database/schema/lifecycle, parser nominal, repository transaksi, kunci sesi dan format/file Drive byte-identical terhadap baseline. Application ID/OAuth/Gateway dipertahankan. Manifest cocok dengan seluruh **170 file** remote.
- Source: https://github.com/rama160/Finchat/archive/refs/heads/codex/finchat-input-navigation-audit.zip . PR: https://github.com/rama160/Finchat/pull/1 .
- **Retest HP:** microphone/segmen ucapan nyata, IME, dialog Google native dan system save picker/lokasi PDF. Bila token Drive tidak tersedia tanpa UI, backup otomatis dilewati sampai pengguna memberi otorisasi lewat menu Backup; data lokal tetap utuh. CI membuktikan kontrak dan layout simulasi, bukan pengujian perangkat fisik.
- Pasang APK sebagai pembaruan aplikasi lama dengan application ID dan signing yang sama; tidak perlu menghapus aplikasi/data. Bagian ini menggantikan status pending pada patch +15 di bawah.

## Spenva device follow-up — 0.3.2+15 (6 Oktober 2026)

- Nama yang tampil menjadi Spenva; application ID `com.finchat.finchat`, nama package Dart, schema/database `finchat.db`, kunci session, backup format/file Drive, Google OAuth, endpoint Gateway dan workflow asli dipertahankan.
- Aset logo sign in/header/launcher terpisah; source SVG berupa outline dan PNG dibundel. Font DejaVu Sans + lisensi, dekorasi dan animasi singkat native Flutter dibundel/offline. Halaman aplikasi dibangun dari widget, bukan gambar pratinjau. Sapaan mengikuti jam lokal perangkat dan nama depan displayName; tanpa nama tidak memakai email sebagai nama.
- Sign in baru mempertahankan Google dan email lokal. Mode offline tanpa email menggunakan `offline@finchat.local`; email lokal lama tetap dapat dimasukkan untuk membuka datanya. Tidak menghapus/migrasi data saat rebranding.
- Rupiah terpusat: `Rp 15.000`, tanpa titik setelah Rp, termasuk respons AI dan PDF. Saldo negatif `-Rp 15.000`.
- Suara mempertahankan hipotesis transaksi lengkap saat Android hanya mengirim frasa terakhir, menggabungkan final/cumulative tanpa duplikasi dan menunggu 400 ms agar final tidak langsung dikonsumsi. Nominal jelas tetap diproses lokal dalam satu batch. Mic Android masih memerlukan retest perangkat.
- Kata pemasukan: gaji/gajian/upah/honor/bonus/komisi/THR/dividen/insentif/hasil penjualan/uang masuk. Bayar upah tetap pengeluaran. MoneyAmountParser dan repository transaksi tidak diubah; tes gaji 5 juta mencakup penyimpanan SQLite dari composer.
- Backup otomatis tidak memanggil authenticate atau attemptLightweightAuthentication. authorizationForScopes hanya mengambil token tanpa UI; bila perlu otorisasi, backup dilewati sampai pengguna menghubungkan Drive lewat tombol yang tersedia. Google lightweight authentication tetap hanya pada jalur AI yang diminta pengguna, bukan backup otomatis.
- Ringkasan laporan adaptif: dua kartu seimbang pada lebar yang cukup, kartu penuh pada layar kecil/teks besar, tanpa ellipsis nominal. Caption dan insight memakai kalimat natural dari data terpilih, tidak mengulang statistik satu hari sebagai pola panjang.
- Kalender tanpa chip Tanggal/Rentang/Bulan/Tahun; pemilih bulan di atas tahun. Klik satu hari lalu Pilih untuk tanggal tunggal; klik hari kedua untuk rentang, klik berikutnya memulai rentang baru. Sebulan penuh/Setahun penuh mempertahankan kemampuan periode penuh. Range sebulan/setahun otomatis dinormalisasi seperti sebelumnya.
- PDF menawarkan Simpan ke perangkat melalui Android file picker atau Bagikan PDF melalui printing. PDF generator, detail/filter dan pemulihan backup tetap berfungsi.
- Status verifikasi: analyze bersih, 119 tes lulus dan signed APK berhasil. Bukti final ada di atas; uji HP tetap diperlukan untuk speech, IME asli, dialog Google dan lokasi penyimpanan Android.

## Current voice capture — 0.3.2+14

Halaman Input menerima satu atau beberapa transaksi suara. Dictation menghasilkan teks final, lalu normalisasi nominal kata/angka masuk ke pipeline lokal yang sama dengan teks. Input yang valid dipetakan kategorinya sebagai satu batch dan disimpan melalui repository; tidak memanggil AI untuk nominal lokal yang sudah jelas. Pertanyaan mengikuti jalur Q&A dan membaca periode dari ucapan. Speech provider sendiri tetap tidak menulis SQLite.

111 tes lulus pada commit `f36a3c11f0bd581e0a4d50f4d9d5d1b20959aa86`, termasuk multi transaksi tanpa AI dan partial/final speech. Android dapat membatasi durasi dan jeda sesi; microphone/perilaku platform masih memerlukan pengujian HP. Catatan Phase 6 di bawah adalah rancangan historis; jalur capture terbaru ini menjadi acuan saat berbeda.

# Phase 6 — Voice Input

## Scope

Voice input converts a short spoken transaction into text. The recognized text is not a transaction by itself. It must enter the existing transaction pipeline:

Voice → speech-to-text → text → normalize → local parser → category engine → validation → AI fallback → review → repository → SQLite.

The speech layer must not write to SQLite and must not bypass the existing parser or validation layers.

## Provider

The first platform adapter uses `speech_to_text`. The domain/application layers depend only on the local `SpeechRecognitionProvider` contract, so the provider can be replaced later without changing transaction logic.

The package is intended for short intermittent speech, which matches transaction-entry commands rather than continuous dictation. See the package documentation for platform support and current limitations.

## Indonesian locale

The application may request `id_ID` when starting a voice session. The final recognition language must still depend on the speech locales installed on the device.

## Android permissions

The Android application needs microphone access and the speech recognition service query required by modern Android targets. The CI Android build generates the platform folder when it is missing; the build workflow therefore patches the generated manifest with the required permissions and recognition-service query.

## Session rules

- initialize once per application/provider instance;
- show listening state to the user;
- accept partial text for preview;
- use final text as the transaction-input candidate;
- allow stop and cancel;
- speech errors do not create transactions;
- empty recognition results do not create transactions.

## CI boundary

Unit tests use a fake speech provider. GitHub Actions does not need a microphone or emulator to verify the domain/application behavior. Real microphone recognition remains a device-level verification step.
