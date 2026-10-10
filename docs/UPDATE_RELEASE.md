# Sinkronisasi, build dan release

**Versi sumber: 0.3.5+20**

## Sumber dan versi

Gunakan **main** untuk clone/ZIP/build harian. UPDATE_GITHUB.bat menargetkan main, stash perubahan lokal saat pull/rebase, memulihkan stash, stage add/update/delete dan push normal. Konflik menghentikan push. Tidak memakai manifest sebagai deletion whitelist; hanya daftar eksplisit instruksi fase, 17 dokumen usang dan empat file source yang dihapus/disatukan boleh dibersihkan. Unduh paket utuh agar file tracked tidak dianggap hilang.

Edit versi hanya pubspec, selalu major.minor.patch+build Android yang meningkat. Jalankan `python3 tooling/sync_metadata.py`; AppConstants dan default release tag mengikuti. Tag release termasuk build (`v0.3.5+20`) agar APK revisi tidak menimpa tag patch lama. UpdateProvider membaca semver dan build; tag historis tanpa build hanya dapat menunjukkan upgrade semver.

## Workflow yang dipertahankan

| Workflow | Tujuan |
|---|---|
| Flutter Test | Source consistency, pub get, analyze, test; upload lockfile |
| Build Android APK | Push main/manual; konfigurasi Android, signing, APK pilot |
| FinChat Audit Validation | APK pilot pada branch audit/integrasi |
| Prepare Play Store AAB | Suite server/tooling/Play, screenshot, native Linux, signed AAB/16KB |
| FinChat Release | Manual publish GitHub release; permanent signing; tag harus cocok pubspec |

Flutter3.47.7 dipin agar SDK tidak berubah diam-diam. Lockfile aplikasi dipulihkan dari Git setelah `flutter create --no-pub`, lalu `flutter pub get --enforce-lockfile` dijalankan; pembuatan runner tidak boleh mengganti dependensi aplikasi. Struktur langkah build dan secret signing dipertahankan. APK pilot menggunakan Gateway lama; AAB Play memakai define distribusi Play dan endpoint tersendiri. Build Play bukan publikasi Console otomatis.

## Pemeriksaan

`python3 tooling/check_repository.py`; `python3 tooling/android/test_configure_android_ci.py`; `python3 tooling/play/test_check_bundle.py`; `node --test server/play-billing/*.test.mjs`; Flutter analyze/test; profile Play; integration Linux; build APK/AAB dan validator manifest/signing/16KB. Source inventory adalah daftar git tracked, diperbarui setelah file dihapus/ditambah. Jangan memasukkan generated platform, cache atau keystore sebagai source.

Pemasangan update memakai app ID dan signing key lama. Jangan uninstall untuk menguji kompatibilitas update data. Publikasi manual tetap memerlukan persyaratan pada [LAUNCH](playstore/LAUNCH.md); unduhan dan SHA build pada [VALIDATION](playstore/VALIDATION.md).
