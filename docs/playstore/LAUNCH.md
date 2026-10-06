> Baseline subscription terbaru 0.3.4+18: [SUBSCRIPTION.md](SUBSCRIPTION.md). Buat enam produk monthly/yearly sesuai konfigurasi final. Kuota Voice/Scan/AI memerlukan ledger akun server; fungsi inti tetap lokal. Tidak ada aktivasi infrastruktur berbayar otomatis. Gemini unpaid hanya dapat menerima fixed topic edukasi tanpa informasi pribadi, dan default belum aktif.

# Spenva — persiapan Google Play 0.3.3+17

Aplikasi belum dipublikasikan. Pemilik belum memiliki Play Console dan belum menetapkan penerbit/email dukungan. Paket ini mempersiapkan AAB, materi listing, dokumen data, kode billing dan pemeriksaan teknis. Approval Google, produk berbayar, provider API billed, email/URL publik dan tes perangkat belum dapat dianggap selesai oleh CI.

## Identitas yang dipertahankan

application ID **com.finchat.finchat**; database **finchat.db**, schema versi 1; OAuth Google dan folder/format Drive lama. Nama pengguna/launcher Spenva. Tiga workflow asli tidak diubah; workflow Play ditambahkan terpisah. Minimum Android 7/API24 mengikuti SDK Billing saat ini. Target Play API36. Build sideload memakai gateway pilot lama; build Play tidak memiliki fallback ke gateway pilot/Unpaid AI. AI pribadi Play tertutup sampai verifikasi kuota dan provider yang sesuai tersedia. Edukasi unpaid hanya fixed topic tanpa informasi pribadi; default nonaktif.

## Langkah pemilik yang diperlukan

1. Buat akun Play Console dengan jenis personal/organisasi yang sesuai, selesaikan verifikasi identitas, pembayaran registrasi dan persyaratan perangkat yang ditampilkan Google. Siapkan profil pembayaran/merchant dan pajak sebelum menjual langganan. Jangan membuat akun menggunakan identitas rekaan.
2. Tentukan nama penerbit publik dan email dukungan aktif. Isi publication-profile.json dan GitHub repository variables SPENVA_PUBLISHER, SPENVA_SUPPORT_EMAIL, SPENVA_PRIVACY_URL, SPENVA_DELETION_URL. Generate legal HTML memakai `python3 tooling/play/render_legal.py --profile ... --output ...`, tinjau lalu host HTTPS publik. Jangan menerbitkan placeholder. URL harus tersedia tanpa login, dapat diakses global, berisi identitas/kontak dan proses penghapusan; bukan PDF.
3. Buat aplikasi Spenva bahasa Indonesia, pilih jenis app, tentukan distribusi gratis (fitur Free) dengan in-app purchases setelah aktif. Masukkan AAB workflow, lalu ikuti Play App Signing. Gunakan upload key permanen yang sudah ada, bukan key CI sementara. Simpan backup key privat dengan aman; jangan masukkan ke repository/artefak.
4. Cocokkan sertifikat **app signing** yang ditampilkan Console dengan Android OAuth client di proyek Google yang sama, package com.finchat.finchat. SHA-1 upload saat ini CA:AA:59:2F:EC:CA:7C:8B:8B:16:C0:83:30:7D:43:A3:25:76:2E:10. Sertifikat upload tidak otomatis sama dengan app-signing key Google. Untuk mempertahankan pembaruan instalasi APK pilot, rencanakan penggunaan signing key yang sama melalui proses impor resmi bila key tersedia; jangan menghapus aplikasi/data pengguna untuk menyelesaikan masalah signature. Uji backup dan migrasi sebelum transisi distribusi.
5. Lengkapi listing, screenshot Android nyata (data demo), kebijakan privasi, URL penghapusan, app access, rating usia, audience dan deklarasi financial features/data safety. Jangan mengklaim tidak mengumpulkan data saat Google/Drive/paid AI digunakan. Tidak ada iklan. AI hanya18+; audience harus sesuai implementasi dan terms Gemini. Jawaban AI tidak boleh menjadi satu-satunya dasar keputusan keuangan.
6. Lakukan internal test dari Play (bukan APK lokal) dan pre-launch report. Uji Google login/restore dengan sertifikat distribusi Play, kamera/lampiran, permission ditolak, suara multi-transaksi, keyboard layar kecil/text besar, gaji, edit/swipe-confirm-delete, PDF save/share, backup dua profil dan penghapusan akun.
7. Jika akun personal baru dibuat setelah13 November2023: minimal **12 tester opted in terus-menerus14 hari**, kemudian ajukan production access. Jangan merekayasa tester atau mengklaim CI memenuhi syarat ini. Catat feedback dan perbaikan selama closed test.
8. Mulai rollout produksi terbatas setelah semua gate ditandai dengan bukti; pantau Android vitals, error dan biaya. Tidak ada upload otomatis dari workflow ini.

## Mengaktifkan langganan setelah akun siap

Ikuti server/play-billing/README.md, buat6 subscription products dengan base plan monthly/yearly sesuai SUBSCRIPTION.md. Gunakan Google Play Billing; kontrak lama QRIS/GoPay/transfer tidak digunakan. Service account Android Publisher API hanya memperoleh izin yang diperlukan untuk membaca/verifikasi subscription dan acknowledge. Private key hanya secret server, tidak diAPK. Buat deployment server terpisah dari gateway pilot.

Google API berbayar harus berasal dari billed project yang sesuai terms dan tidak memakai endpoint gratis untuk data finansial pribadi. PAID_AI_CONFIRMED default false. Siapkan KV feedback dan Durable Object quota baru, operator moderasi laporan in-app dan proses penghapusan eksternal. Tetapkan GitHub variable SPENVA_BILLING_ENDPOINT hanya setelah uji end-to-end. Pembelian belum aktif hanya karena tombol paket/catalog tersedia.

Tes sandbox: pending tidak membukaAI; purchased diverifikasi/ack server; restored akun yang sama; akun lain ditolak; canceled aktif sampaiexpiry; expired/on-hold/paused/refunded ditolak; offline tidak granting; kuota Voice/Scan/AI sesuai katalog final, reserve atomic dan failure refund; laporan in-app benar-benar masuk dan operator meninjau. Verifikasi harga Google Play yang terlihat pengguna. Android RTDN belum dipakai: entitlement diverifikasi ke Google setiap panggilanAI, bukan dipercaya dari cache. Tidak ada recurring charger buatan aplikasi.

## Build dan gate

Workflow `.github/workflows/play_store.yml` menghasilkan signed AAB+APK validasi, SHA256, manifest, bundle config dan validation.json. Memeriksa paket/version, SDK36, cleartextfalse, izin minimal dan alignment ELF/ZIP16KB. Signature menggunakan secret signing lama. Production gate terpisah:

`python3 tooling/play/check_bundle.py --bundle=... --manifest=... --config=... --profile=... --output=... --require-publication`

Isi status boolean hanya setelah bukti benar. Pemeriksaan statis/alignment tidak menggantikan runtime perangkat16KB, Play pre-launch report, realbillingtest atau persetujuanGoogle. Jangan menyebut AAB persiapan sebagai rilis publik siap jual sebelum gate selesai.

Sumber resmi diperiksa6 Oktober2026:
- API36: https://support.google.com/googleplay/android-developer/answer/11926878
- Account/testing: https://support.google.com/googleplay/android-developer/answer/14151465
- Data/deletion: https://support.google.com/googleplay/android-developer/answer/10144311 ; https://support.google.com/googleplay/android-developer/answer/13327111
- Data safety: https://support.google.com/googleplay/android-developer/answer/10787469
- AI report: https://support.google.com/googleplay/android-developer/answer/13985936
- 16KB: https://developer.android.com/guide/practices/page-sizes
- Google branding: https://developers.google.com/identity/branding-guidelines
- Gemini terms: https://ai.google.dev/gemini-api/terms
