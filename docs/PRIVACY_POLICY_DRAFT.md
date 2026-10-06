# Kebijakan Privasi Spenva — Draft untuk Release

Terakhir diperbarui: 6 Oktober 2026

Spenva adalah aplikasi pengelolaan keuangan pribadi dengan pendekatan local-first. Data transaksi utama disimpan pada perangkat pengguna. Kebijakan ini harus dipublikasikan pada URL HTTPS publik sebelum pengajuan Google Play.

## Data dan tujuan penggunaan
- Akun Google: digunakan untuk autentikasi, pengaitan sesi, Google Drive, dan verifikasi entitlement layanan yang memerlukan akun.
- Data transaksi keuangan: digunakan untuk pencatatan, kategori, laporan, dan pertanyaan keuangan yang diminta pengguna.
- Kamera/gambar struk: digunakan untuk OCR struk. Hasil OCR harus ditinjau sebagai data tidak tepercaya sebelum menjadi transaksi.
- Mikrofon/suara: digunakan untuk mengubah ucapan menjadi input transaksi.
- Google Drive: digunakan untuk backup/restore pada appDataFolder setelah pengguna memberikan izin.
- AI: parser lokal digunakan lebih dahulu. Permintaan yang membutuhkan AI dapat dikirim melalui gateway Spenva setelah autentikasi; credential penyedia AI tidak disimpan di APK.
- Data subscription: status paket dan token pembelian diproses untuk memverifikasi hak akses. Backend menyimpan hash token untuk indeks dan status entitlement; rahasia Google Play tidak disimpan di APK.

## Penyimpanan dan keamanan
SQLite adalah sumber data utama di perangkat. Metadata sesi sensitif menggunakan secure storage. Komunikasi layanan online menggunakan HTTPS. Kredensial backend dan penyedia AI tidak boleh dimasukkan ke aplikasi.

## Pembayaran
Pembelian paket digital pada distribusi Google Play diproses melalui Google Play Billing. Spenva memverifikasi status langganan melalui backend dan Google Play Developer API.

## Penghapusan
Sebelum production, aplikasi dan halaman publik harus menyediakan proses penghapusan akun/data yang sesuai dengan implementasi aktual. Jangan mempublikasikan draft ini sebagai final sebelum alur penghapusan tersebut tersedia dan Data Safety telah diaudit.

## Kontak
REPLACE_WITH_PUBLIC_SUPPORT_EMAIL
