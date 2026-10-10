# Arsitektur implementasi

**Versi sumber: 0.3.5+20**

| Lapisan | Tanggung jawab | Sumber penting |
|---|---|---|
| Presentation | UI, lifecycle, navigasi, konfirmasi, pemilihan periode | ChatScreen, ReportScreen, BackupScreen, AppRouter |
| Application | Orkestrasi parser/learning/backup/QA/billing/session | TransactionIntelligenceService, BackupService, ReportService, PlayBillingService |
| Domain | Entity, kontrak repository/provider, kalkulasi murni | TransactionEntity, BackupSnapshot, SelectedPeriod, AI/OCR/speech interfaces |
| Data | SQLite, secure storage, HTTP, native plugin adapter | FinChatDatabase, Sqlite repositories, MLKit/Speech/Drive/Gateway adapters |

## Alur utama

Teks/voice → intent → local parser → learning → validator → saveAll SQLite. Pertanyaan → questionPeriod → ReportService → jawaban lokal → optional AI read-only. Struk → preprocessing temporary JPEG → ML Kit → ReceiptTransactionParser → learning → review → saveAll. Speech provider tidak menulis database; AI tidak boleh mengubah nominal atau menulis transaksi.

FinChatDatabase default adalah singleton shared; screen close tidak menutup koneksi. Factory/path khusus menghasilkan database terisolasi untuk tes. Schema1 memakai foreign keys. Edit memakai UPDATE (bukan replace-delete) agar category_history yang direstore tetap valid. Category defaults berasal dari satu map, digunakan initial seed dan repair missing legacy categories.

SessionManager mengelola session tersimpan; GoogleSignInCoordinator mengelola satu Google initializer, akun dan token singkat. GoogleAuthService adalah adapter login. GoogleDriveAuthService mengatur consent Drive appDataFolder dan membaca akun dari coordinator yang sama; tidak menyimpan akun stale sendiri. Perbedaan adapter auth/Drive bukan dua login state.

AppRouter dimiliki State aplikasi; listener/provider didispose; page keys berubah ketika akun/login berubah. Halaman setting/backup/privasi/receipt adalah route di atas root. Report adalah tab yang kembali ke Input saat Back.

## Backup, kuota dan privasi

Backup snapshot membaca enam tabel pada satu transaksi; validasi seluruh schema/types/IDs/references sebelum restore. Restore satu transaksi dengan insert-abort rollback. Legacy local_user dimapping hanya pada jalur kompatibilitas. Drive acknowledgement hanya baris dengan updated_at yang sama saat export. DataOperationGate menserialkan cloud backup/deletion.

Play quota ledger di server di luar backup: logout/reinstall/restore tidak meresetnya. Client entitlement tidak dapat mengaktifkan paket tanpa verifikasi server. Token/session di secure storage; SQLite keuangan tidak dienkripsi khusus aplikasi. Penghapusan profil aktif bukan penghapusan seluruh profil atau pembatalan Google Play subscription.

## Build dan sumber konfigurasi

Android/Linux folder dibuat oleh CI saat tidak ada; configure_android_ci.py mengatur signing/perizinan/branding/R8. configure_play.py menambahkan target API36/cleartext/broad-permission policy secara idempotent. Pubspec version, package catalog JSON, default category map dan privacy text masing-masing punya satu otoritas. File generated dan manifest inventory diperiksa oleh check_repository.py. Flutter dipin 3.47.7; pubspec.lock hasil teruji disimpan untuk dependency reproducibility.

Dokumentasi current tidak memuat preamble release lama. Riwayat tersedia pada Git commit melalui [indeks](history/README.md). Bukti executable hanya [VALIDATION](playstore/VALIDATION.md).
