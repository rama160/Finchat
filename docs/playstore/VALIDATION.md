> Current source status: **0.3.4+19**, 9 October 2026 UTC. See [../SPENVA_CANONICAL_SOURCE.md](../SPENVA_CANONICAL_SOURCE.md) and the current detailed audit. Older version/build statements below are historical evidence and do not verify this patch.

# Verifikasi subscription Spenva 0.3.4+18 — 6 Oktober 2026

Runtime yang diuji: `7bfd653d6dfe3a893c1c2252a1f345f48f5a9122`, branch `codex/finchat-input-navigation-audit`. Commit dokumentasi sesudahnya tidak mengubah runtime atau artefak. Hasil ini menggantikan +17; catatan lama di bawah hanya riwayat.

## Hasil GitHub CI

- [Flutter Test](https://github.com/rama160/Finchat/actions/runs/37464173463): success; Flutter 3.47.6, analyze tanpa issue; **134 tes lulus, 2 skipped**. Capture screenshot dan guard khusus Play dijalankan terpisah.
- [Prepare Play Store AAB](https://github.com/rama160/Finchat/actions/runs/37464173519): kedua job prepare/integration success. Suite normal 134 lulus/2 skipped; suite profile Play **11 lulus/1 skipped**, dengan tes pilot sengaja tidak dijalankan pada Play.
- Backend subscription/kuota **46 tes lulus**; validator bundle **5 tes lulus**; generator katalog `--check` lulus. Upstream pembayaran memakai simulasi dan kunci RSA tes, bukan pembayaran sungguhan.
- Integrasi native Linux **1 tes lulus**: mode offline, multi transaksi nasi/bakso/gaji, database, laporan dan kembali ke input.
- Capture **4 layar**, 1080×1920 RGB, menggunakan aset/font bundle. Ini bukan bukti pengujian HP atau persetujuan desain.
- Signed AAB **75.1 MB**, versi **0.3.4+18**; jarsigner, manifest, ELF 64-bit 16 KB, bundle alignment 16 KB dan universal APK zipalign `-P 16` lulus.
- Application ID `com.finchat.finchat`, min API24/target API36; tanpa izin storage luas/cleartext pada profile Play.
- Manifest cocok dengan **216 file** remote. Tiga workflow asli, workflow audit, UPDATE_GITHUB.bat, database, SessionManager, parser lokal, BackupService dan provider Drive identik dengan snapshot sebelum subscription.
- Main tetap `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`; PR tidak di-merge.

## Unduhan

- [AAB + APK validasi + laporan teknis](https://github.com/rama160/Finchat/actions/runs/37464173519/artifacts/11413279142). SHA256 arsip: `f71029d0139ab5b24809a73f677d19eec6349315830484870277c986637c67d3`.
- [Empat screenshot untuk review](https://github.com/rama160/Finchat/actions/runs/37464173519/artifacts/11413962943). SHA256 arsip: `69689a5e6c9abf5a728b1071813fbe900beb2a104d2d10689a93a215071a9dc4`.
- [PR1](https://github.com/rama160/Finchat/pull/1) tetap draft. Artefak berakhir **4 Januari 2027**. Gunakan AAB untuk Console; APK universal untuk validasi.
- Dokumentasi final di repository lebih baru daripada salinan panduan dalam arsip build.

## Status aktivasi

Sistem diimplementasikan sesuai [SUBSCRIPTION.md](SUBSCRIPTION.md): Free/Plus/Pro/Max, enam produk bulanan/tahunan, kuota Voice/Scan/AI server terpisah dan Free PDF 1 ekspor sukses/bulan. Logout/reinstall/restore tidak mereset counter; paket tahunan tetap mengisi kuota bulanan. Pembatalan memberi akses sampai expiry.

**Pembelian belum live dan server subscription belum di-deploy.** Produk/base plan Play Console, Android Publisher service account, KV/DO server baru dan SPENVA_BILLING_ENDPOINT masih perlu dikonfigurasi serta diuji. Gateway pilot dipertahankan. Tidak ada infrastruktur berbayar atau personal AI yang diaktifkan otomatis.

Validator mencatat **9 syarat publikasi belum terpenuhi**: identitas penerbit, email dukungan, URL privasi/penghapusan, akun Console, OAuth Play App Signing, review Data Safety/screenshot serta closed test bila diwajibkan. Gate subscription/provider tambahan berlaku setelah endpoint/AI diaktifkan.

CI bukan tes pembayaran Play atau HP. Sebelum publikasi, uji pembelian/renew/cancel/grace/expiry/refund, restore lintas perangkat, Voice/OCR, kuota bersamaan, OAuth Play App Signing, backup/deletion, keyboard/teks besar serta perangkat 16 KB dari distribusi Play. Lihat [LAUNCH.md](LAUNCH.md).

## Riwayat hasil +17

### Hasil persiapan Play 0.3.3+17 — 6 Oktober 2026

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
