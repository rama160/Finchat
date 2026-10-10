# Status dan keputusan canonical

**Versi sumber: 0.3.5+20**

## Sumber dan identitas

**main** adalah sumber build, ZIP dan sinkronisasi harian. Versi sumber berasal dari pubspec, disalin otomatis ke AppConstants dan default tag release. Nama produk Spenva; nama package Dart tetap finchat, Android com.finchat.finchat, database finchat.db schema1. Identitas ini dipertahankan untuk pembaruan instalasi lama.

## Perilaku saat ini

| Area | Implementasi | Batas |
|---|---|---|
| Akun | Offline tanpa email atau email lokal lama; Google SSO; secure session; token Google singkat di memori | OAuth Android memerlukan package dan SHA-1 signing yang sesuai |
| Input | Local parser, normalisasi suara, OCR on-device dengan review; penyimpanan batch atomik; swipe edit/hapus | Speech/kamera/picker memerlukan uji HP |
| Laporan | Periode tanggal/rentang/bulan/tahun; total, pie, harian, insight; PDF save/share | Plugin save/share perlu uji HP |
| Backup | JSON UTF-8, enam tabel snapshot konsisten, legacy restore, manual/auto Drive | Whole-database; termasuk profil lain; auto melewati izin yang belum tersedia |
| AI | Jawaban faktual lokal; pilot Gateway; Play endpoint terpisah dengan consent dan kuota | Provider live dan konfigurasi eksternal bukan bukti tes mock |
| Paket | Free/Plus/Pro/Max, harga/kuota generated dari satu JSON | Katalog tampil; server/product Play belum diaktifkan |
| Privasi | Penghapusan akun aktif lokal dan opsi Drive/server; profiling lain dipertahankan | Salinan ekspor/perangkat lain dan pembatalan subscription perlu tindakan terpisah |

Harga/kuota lengkap: [PLANS](playstore/PLANS.md). Tidak ada QRIS/GoPay/checkout eksternal untuk langganan digital. Play Billing adalah jalur pembayaran yang disiapkan. Tidak ada aktivasi otomatis backend atau personal AI.

## Sumber tunggal dan batas modul

Versi → pubspec; katalog paket → JSON; kategori default → category_entity.dart; privacy content → assets/legal/privacy_id.txt; publikasi → publication-profile.json plus override GitHub variables. AppConstants, generated_plans.dart, plans.generated.mjs dan PLANS.md adalah output generasi yang diperiksa.

Interface domain menentukan kontrak, application mengatur operasi, data menangani SQLite/HTTP/plugin, presentation menampilkan UI. Modul-modul ini bukan duplikasi. Halaman QA lama, external-payment stub, error hierarchy yang tidak dipakai serta normalizer suara kedua sudah dihapus/disatukan.

## Status verifikasi

Hasil runtime saat ini dan tautan build hanya pada [VALIDATION](playstore/VALIDATION.md). Detail per file: [audit](FULL_REPOSITORY_AUDIT.md). Riwayat: [arsip](history/README.md). Persyaratan yang perlu pemilik/perangkat tetap pada [LAUNCH](playstore/LAUNCH.md). Kesiapan source/build tidak sama dengan publikasi Play selesai.
