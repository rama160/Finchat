# AI START HERE — Spenva / FinChat

**Versi sumber: 0.3.5+20**

Repository `rama160/Finchat`. Target akhir dan sumber utama pengguna: **main**. Branch `spenva-source-of-truth` hanya staging integrasi; sesudah CI hijau gabungkan ke main agar tampilan default GitHub, ZIP dan `pubspec.yaml` benar-benar sama. Jangan menyatakan pembaruan main selesai sebelum membaca ulang remote main.

Baca: [status canonical](docs/SPENVA_CANONICAL_SOURCE.md), [PRD](docs/PRD.md), [arsitektur](docs/ARCHITECTURE.md), [kontrak AI](docs/AI_CONTRACT.md), [audit setiap file](docs/FULL_REPOSITORY_AUDIT.md), [validasi](docs/playstore/VALIDATION.md), lalu CHANGELOG dan implementasi. Riwayat lama hanya pada [indeks arsip](docs/history/README.md).

Aturan perubahan:
- Pertahankan Google login/session mapping email, application ID, kunci signing, SQLite schema1, data lama, backup legacy, branding serta UX input/laporan yang sudah berjalan.
- SQLite adalah sumber transaksi. Parser/perhitungan lokal didahulukan. AI tidak menulis database; kegagalan AI tidak menghilangkan hasil lokal.
- Satu sumber versi: pubspec. Satu katalog paket: JSON. Satu katalog kategori: systemCategoryDefaults pada category_entity.dart. Output generated bukan konfigurasi manual kedua.
- Background Drive tidak menampilkan dialog autentikasi. Backup whole-database tetap dengan konfirmasi sebelum restore; validasi berjalan sebelum delete dan rollback mempertahankan data jika insert gagal. Acknowledgement memakai versi baris, bukan seluruh baris baru.
- Hapus hanya dead code/instruksi duplikat/cache yang terkonfirmasi. Jangan menggabungkan interface, adapter platform dan layanan bisnis hanya karena nama fiturnya sama.
- Jangan force-push, mengubah signing, mengaktifkan subscription/personal AI, melakukan publikasi atau menyalakan infrastruktur berbayar sebagai efek audit.

Perubahan versi: edit pubspec → `python3 tooling/sync_metadata.py` → generator paket jika perlu → `python3 tooling/check_repository.py`. Build memakai Flutter 3.47.7 agar konsisten dengan SDK yang diuji. Jalankan tes backend/tooling/Flutter/profil Play/native integration, signed APK dan AAB/16KB. Catat SHA yang benar dan tautan run pada VALIDATION; hasil versi lama tidak mengesahkan runtime baru.

Local Flutter initialization sebelumnya diblokir automatic review karena percobaan akses metadata-service. Jangan mengulang jalur tersebut; gunakan GitHub CI untuk analyze/test/build. Formatter Dart mandiri dan tes Node/Python tersedia lokal.

Handoff harus mencatat source/version, sebab dan perbaikan per file, schema impact, bukti tes/build, perubahan branch main serta acceptance perangkat/layanan eksternal yang belum dilakukan. Jangan mengklaim CI sebagai uji HP atau simulasi billing sebagai pembelian nyata.
