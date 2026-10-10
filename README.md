# Spenva — pencatat keuangan pribadi

**Versi sumber: 0.3.5+20**

Sumber utama repository dan ZIP adalah branch **main**. `spenva-source-of-truth` adalah branch integrasi audit menuju main; bukan sumber kedua yang harus disalin manual. Panduan masuk: [Ai start here.md](Ai%20start%20here.md). Spesifikasi saat ini: [PRD](docs/PRD.md), [arsitektur](docs/ARCHITECTURE.md), [status canonical](docs/SPENVA_CANONICAL_SOURCE.md).

Spenva mencatat transaksi melalui teks, suara atau review struk; belajar kategori; menampilkan laporan dan PDF; menyediakan login lokal/Google serta backup pilihan pengguna. Logo dan font dibundel dan tetap tampil offline. Identitas Android `com.finchat.finchat`, database `finchat.db` schema1 dan format backup lama dipertahankan.

Versi hanya diedit pada `pubspec.yaml`. Jalankan `python3 tooling/sync_metadata.py` untuk menyelaraskan versi Pengaturan dan tag release. Harga/kuota hanya diedit di `assets/config/subscription_plans.json`; jalankan `python3 tooling/play/generate_subscription.py`. Hasil generasi wajib identik melalui pemeriksaan CI.

Untuk Windows: unduh ZIP **main**, ekstrak satu paket utuh, jalankan `UPDATE_GITHUB.bat "pesan perubahan"`. BAT menargetkan main dan tidak force-push. Jangan menimpa paket terbaru dengan ZIP branch lama. [Panduan build/update](docs/UPDATE_RELEASE.md).

Validasi dan unduhan APK/AAB yang benar tercatat di [VALIDATION](docs/playstore/VALIDATION.md). [Audit per file](docs/FULL_REPOSITORY_AUDIT.md) memisahkan gap yang diperbaiki, modularitas yang dipertahankan dan batas uji.

Mode pilot/sideload mempertahankan alur yang sudah berjalan. Build Play mempunyai verifikasi kuota Voice/Scan/PDF/AI; backend yang belum dikonfigurasi membuat fitur tersebut belum tersedia. Teks, database, kategori, pertanyaan lokal dan laporan dasar tetap tersedia. Subscription dan personal AI belum diaktifkan; kesiapan publikasi mengikuti [LAUNCH](docs/playstore/LAUNCH.md), bukan keberhasilan build saja.
