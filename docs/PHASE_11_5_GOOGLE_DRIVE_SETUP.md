# Phase 11.5 — Google Drive Setup

## Tujuan
FinChat menggunakan Google Sign-In untuk otorisasi Google Drive dan menyimpan backup pada `appDataFolder`, sehingga file backup tidak muncul sebagai file biasa di Drive pengguna.

## 1. Google Cloud
1. Buat/pilih project Google Cloud.
2. Aktifkan Google Drive API.
3. Konfigurasi OAuth consent screen.
4. Tambahkan scope Drive App Data sesuai kebutuhan aplikasi.
5. Buat OAuth Client ID untuk Android.
6. Masukkan package name Android FinChat dan SHA-1 signing certificate yang benar.

## 2. Aplikasi
Dependency yang digunakan:
- `google_sign_in: ^7.2.0`
- `extension_google_sign_in_as_googleapis_auth: ^3.0.0`
- `googleapis_auth: ^2.3.4`
- `googleapis: ^17.0.0`

`google_sign_in` memisahkan authentication dan authorization pada API modern; akses Drive diminta hanya saat pengguna menjalankan fitur backup/restore. Bridge extension mengubah authorization Google Sign-In menjadi authenticated client untuk `googleapis`. 

## 3. Alur
`Hubungkan Google → authorize Drive appDataFolder → GoogleDriveBackupProvider → BackupService`.

Tidak ada token OAuth yang ditulis ke SQLite oleh FinChat. Kredensial dikelola oleh Google Sign-In/OS.

## 4. Verifikasi Phase 11.5
Jalankan `flutter analyze` lalu `flutter test`. Pengujian Google account/Drive dan file picker dilakukan pada device di Phase 11.7 sesuai keputusan proyek.
