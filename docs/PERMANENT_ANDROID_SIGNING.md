# FinChat Android: permanent release keystore with GitHub Actions

Workflow ini memakai satu release keystore yang dibuat sekali oleh pemilik repository. File keystore tidak disertakan dalam ZIP dan tidak boleh dikomit ke Git.

## 1. Buat keystore satu kali (Windows PowerShell)

Pastikan JDK `keytool` tersedia. Jalankan perintah berikut di folder aman. Gunakan password kuat dan simpan di password manager:

```powershell
keytool -genkeypair -v -keystore finchat-upload.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias finchat-upload
keytool -list -v -keystore finchat-upload.jks -alias finchat-upload
```

Simpan fingerprint SHA-1 yang ditampilkan. SHA-1 saja tidak dapat merekonstruksi private key/keystore. Buat backup keystore yang aman dan jangan regenerasi untuk build rutin.

## 2. Encode keystore

Di PowerShell, dari folder berisi `finchat-upload.jks`:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path .\finchat-upload.jks))) | Set-Clipboard
```

Salin hasil clipboard langsung ke GitHub Secret; jangan letakkan di source, issue, chat, atau log.

## 3. Tambahkan GitHub Actions Secrets

Repository → **Settings → Secrets and variables → Actions → New repository secret**. Tambahkan:

| Nama Secret | Isi |
|---|---|
| `FINCHAT_UPLOAD_KEYSTORE_BASE64` | Base64 keystore |
| `FINCHAT_KEY_ALIAS` | `finchat-upload` (atau alias yang dipilih) |
| `FINCHAT_KEY_PASSWORD` | Password key alias |
| `FINCHAT_STORE_PASSWORD` | Password keystore |
| `FINCHAT_GOOGLE_SERVER_CLIENT_ID` | Google Web/server OAuth Client ID yang sudah dipakai FinChat |

Jangan masukkan Gemini API key untuk signing APK; Gemini key tetap hanya di Cloudflare Worker Secrets.

## 4. Daftarkan SHA-1 Android OAuth

Di Google Cloud Console → APIs & Services → Credentials, buat/perbarui Android OAuth client dengan SHA-1 permanen dan package name Android yang tepat. Karena Android project pada repo ini dibuat di workflow jika belum ada, periksa `applicationId` pada `android/app/build.gradle` atau `.kts` di log/hasil run sebelum mendaftarkan package name; harus sama persis. Jangan menebak package name.

`FINCHAT_GOOGLE_SERVER_CLIENT_ID` harus berisi Web/server OAuth client ID, bukan Android OAuth client ID. OAuth client IDs adalah identifier, bukan API secret.

## 5. Jalankan build

Push ke branch `main`, atau buka **Actions → Build Android APK → Run workflow**. Workflow memerlukan semua secrets, mengembalikan keystore yang sama ke runner, menampilkan SHA-1 publik, membangun APK release, lalu mengunggah artifact `finchat-release-apk`. Jika secret belum lengkap, job sengaja gagal dan tidak membuat APK dengan debug key sementara.

`android/key.properties` dan `android/app/upload-keystore.jks` hanya dibuat pada runner dan tidak ikut dikomit. Hasil build tetap perlu diuji di perangkat untuk memastikan Google Sign-In bekerja.

## Catatan migrasi

APK lama yang ditandatangani dengan keystore sementara akan memiliki SHA-1 berbeda. Pasang APK baru untuk uji. Jika aplikasi sudah didistribusikan, pergantian signing key dapat menghalangi pembaruan in-place kecuali proses upgrade key yang sesuai di app store digunakan. Simpan keystore permanen secara aman; kehilangan file atau password dapat menghalangi rilis pembaruan berikutnya.
