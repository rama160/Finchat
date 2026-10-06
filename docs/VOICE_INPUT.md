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
- Status verifikasi: menunggu GitHub analyze/tests/signed APK. Uji HP tetap diperlukan untuk speech, IME asli, dialog Google dan lokasi penyimpanan Android.

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
