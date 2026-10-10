# Google login dan Drive

**Versi sumber: 0.3.5+20**

Google login menggunakan web OAuth client ID sebagai serverClientId dan Android OAuth client dengan package `com.finchat.finchat` serta SHA-1 signing certificate yang sesuai. Default client ID lama dipertahankan. Override build melalui GitHub secret FINCHAT_GOOGLE_SERVER_CLIENT_ID; jangan menggunakan Android client ID sebagai server audience.

Sideload menggunakan SHA-1 upload/release key. Distribusi Play menggunakan SHA-1 App Signing dari Console; ini dapat berbeda dari upload key. Application ID sama. Audience verifikasi Gateway/backend harus cocok dengan serverClientId. Jangan mengubah ID/key yang sudah bekerja untuk mengatasi mismatch tanpa bukti.

GoogleSignInCoordinator satu initializer untuk Google Sign-In7; current account/token shared. Session userId tetap email lowercase agar transaksi profil lama terbaca. Token ID hanya disimpan sementara di memori dan diperbarui pada request foreground; session metadata berada di secure storage.

Drive meminta hanya `https://www.googleapis.com/auth/drive.appdata`. Pengguna memberi izin melalui Backup → Hubungkan Google Drive. File tetap `finchat_backup.json` di appDataFolder, whole-database termasuk profil lokal lain. Manual backup boleh menampilkan consent; automatic backup hanya authorizationForScopes tanpa prompt dan melewati token/izin yang belum tersedia. Client auth ditutup setelah setiap operasi.

Logout coordinator harus segera tercermin pada auth Drive; akun lama tidak dicache pada service kedua. Restore/deletion memeriksa akun dan scope sesuai layar. Mengganti akun Drive bukan migrasi transaksi otomatis.

Verifikasi HP: login → restart → profil lama → manual backup → background capture tanpa dialog Google → logout → akun berbeda → restore backup valid → cancelled/denied consent → deletion dengan cloud failure. Untuk Play, lakukan dari paket yang didistribusikan Console; unit tests tidak membuktikan konfigurasi OAuth provider.
