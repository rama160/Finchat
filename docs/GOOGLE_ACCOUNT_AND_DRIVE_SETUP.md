# Google Account, Sign-In, and Drive Setup

Dokumen ini menggabungkan setup Google Sign-In dan Google Drive yang sebelumnya terpisah.

## Google Sign-In

# Google Sign-In FinChat

## Tujuan

FinChat sekarang memiliki fondasi akun multi-user dengan Google Sign-In. Alur yang dipakai adalah satu tombol `Lanjut dengan Google`; pengguna baru dan pengguna lama sama-sama menggunakan alur Google yang sama. Pembuatan akun Google sendiri tetap dilakukan oleh Google.

## Yang aktif sekarang

- Google Sign-In pada application/session layer.
- Session menyimpan provider (`google`) dan Google user ID di secure storage.
- `userId` lokal tetap menggunakan email yang dinormalisasi agar data SQLite FinChat yang sudah ada tidak kehilangan referensi ketika pengguna beralih dari login email lokal ke Google.
- ID token hanya berada di memori hasil autentikasi dan tidak ditulis ke SQLite atau secure storage.
- Tombol keluar melakukan Google sign-out dan tetap membersihkan sesi lokal jika sign-out Google gagal.

## Konfigurasi Android

1. Di Google Cloud Console, buat atau gunakan project untuk FinChat.
2. Konfigurasikan OAuth consent screen dan OAuth client Android.
3. Tambahkan package name Android FinChat dan SHA-1 untuk debug/release sesuai build yang diuji.
4. Untuk build lokal yang memakai Google Services, tempatkan `google-services.json` sesuai konfigurasi Gradle. Untuk GitHub Actions pada repository ini, cara yang dipakai adalah GitHub Actions Secret `FINCHAT_GOOGLE_SERVER_CLIENT_ID`, sehingga secret tidak ditulis ke source code.
5. Pastikan OAuth client Android mencantumkan package name yang benar dan SHA-1 untuk sertifikat build yang diuji.
6. Jalankan `flutter pub get` dan build ulang.

Project ini tidak menyimpan client secret di APK. Client ID Android bukan secret; API key/backend credential tetap harus disimpan di server.

## Backend AI bersama

Jika FinChat nanti memakai satu Gemini API milik aplikasi, backend harus memverifikasi ID token Google melalui HTTPS sebelum membuat sesi backend. Jangan percaya email atau user ID yang dikirim client tanpa verifikasi token.

Untuk build GitHub Actions, tambahkan repository secret bernama `FINCHAT_GOOGLE_SERVER_CLIENT_ID` berisi OAuth Web/Server Client ID. Workflow akan meneruskannya sebagai `dart-define`; secret tidak masuk ke source code. Untuk build lokal, gunakan:

```text
--dart-define=FINCHAT_GOOGLE_SERVER_CLIENT_ID=<WEB_SERVER_CLIENT_ID>
```

Nilai tersebut adalah OAuth web/server client ID, bukan API key Gemini.

## Pengujian

Pengujian Google Sign-In nyata harus dilakukan pada Android device setelah OAuth client dan SHA-1 dikonfigurasi. CI hanya memverifikasi kontrak/session logic dan tidak dapat membuktikan OAuth provider nyata tanpa credential/configuration milik aplikasi.

## Google Drive Backup

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
