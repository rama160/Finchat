# Hasil verifikasi persiapan Play — 6 Oktober 2026

Runtime yang diuji: `6dbfebc49705ab1ba70efe3a844cce529f70f772`, versi **0.3.3+17**. Perubahan dokumentasi/ikon listing setelah commit ini tidak mengubah AAB atau runtime.

## Hasil CI

- [Play preparation run](https://github.com/rama160/Finchat/actions/runs/37422381588): **success**.
- [Flutter test run](https://github.com/rama160/Finchat/actions/runs/37422381640): **success**, analyze tanpa issue; **125 tests passed, 1 skipped**. Capture store sengaja skipped pada suite normal dan dijalankan terpisah.
- Suite khusus build Play: **5 tests passed**.
- Backend billing: **17 tests passed**, memakai kunci RSA dan respons upstream simulasi, bukan pembayaran Play sungguhan.
- Validator bundle: **3 tests passed**.
- Capture empat layar widget aplikasi berhasil; logo/font dibundel dan dimuat sebelum capture. Gambar 1080×1920 RGB diperiksa visual; bukan bukti pengujian perangkat Android.
- Signed AAB **74.9 MB** berhasil dibangun. `jarsigner -verify` berhasil; pemeriksaan manifest, ELF 64-bit 16 KB, konfigurasi bundle 16 KB dan universal APK `zipalign -P 16` lulus.
- Application ID `com.finchat.finchat`, versi 17, min API24/target API36; broad storage permissions dan cleartext tidak digunakan pada profile Play.
- Tiga workflow asli dibandingkan dengan snapshot sebelum persiapan Play: byte-identical. Database schema1, identitas aplikasi dan sesi Google tetap dipertahankan.

## Unduhan

- [AAB + APK validasi + laporan teknis](https://github.com/rama160/Finchat/actions/runs/37422381588/artifacts/11394012086). SHA256 arsip: `a6294de4f4d77a4d82c1ed87b6b4a4bcdfdf1333b2f5eaeefd56e06edfbfac1e`.
- [Empat screenshot untuk review](https://github.com/rama160/Finchat/actions/runs/37422381588/artifacts/11393776723).
- Untuk listing, gunakan **store-icon.png terbaru pada repository**. Ikon dalam arsip build dibuat sebelum koreksi latar sudut ikon listing; AAB dan ikon launcher tidak berubah. Feature graphic dan panduan listing tersedia pada folder ini.

Artefak Actions memiliki masa simpan sampai 4 Januari 2027. Simpan hasil unduhan untuk proses Console; jangan memakai APK validasi sebagai pengganti AAB upload.

## Belum selesai / tidak diklaim oleh CI

Validator melaporkan **9 persyaratan publikasi belum terpenuhi** pada profile saat ini. Belum ada akun Console, penerbit/email dukungan, URL privasi/penghapusan publik, verifikasi OAuth dengan Play App Signing, review Data Safety/screenshot dan closed test bila diwajibkan. Build persiapan belum rilis publik.

Langganan belum diaktifkan. Free tetap lokal; backend verification terpisah sudah disiapkan, tetapi produk Play, service account, deployment, billed AI, reporting operasional dan tes transaksi dari Play belum tersedia. Tidak ada deployment worker atau penagihan baru selama persiapan ini. Gate tambahan wajib dipenuhi bila backend paid diaktifkan.

Alignment statis bukan tes runtime perangkat16KB. Google login dari Play, backup/restore lintas profil, penghapusan online, kamera/suara/OCR, layar kecil/text besar/keyboard, payment lifecycle dan Play pre-launch report tetap perlu diuji pada distribusi Play. Lihat LAUNCH.md dan publication-profile.json.
