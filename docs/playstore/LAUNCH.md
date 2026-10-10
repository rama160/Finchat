# Persiapan publikasi Play

**Versi sumber: 0.3.5+20**

AAB dapat lulus teknis sementara aplikasi belum siap publikasi. Daftar di bawah adalah **9 blocker profile repository**, bukan daftar seluruh kebijakan Google. Nilai saat ini dibaca oleh tooling/play/check_bundle.py dari publication-profile.json dan environment build.

| No | Key blocker | Yang harus dilengkapi/verifikasi |
|---|---|---|
|1|publisher|Nama penerbit publik yang sebenarnya|
|2|support_email|Email dukungan aktif|
|3|privacy_url|Halaman HTTPS kebijakan privasi publik|
|4|deletion_url|Halaman HTTPS permintaan penghapusan tanpa aplikasi|
|5|play_console_account|Akun Console dan verifikasi yang diperlukan|
|6|app_signing_oauth_verified|OAuth com.finchat.finchat dengan SHA-1 App Signing diuji dari distribusi Play|
|7|data_safety_reviewed|Deklarasi sesuai perilaku final/data provider ditinjau|
|8|store_screenshots_reviewed|Empat screenshot actual app/listing diperiksa pemilik|
|9|closed_test_completed_if_required|Closed testing sesuai persyaratan akun selesai atau tidak diwajibkan secara terverifikasi|

Identitas/contact/URLs dapat diisi dari GitHub variables SPENVA_PUBLISHER, SPENVA_SUPPORT_EMAIL, SPENVA_PRIVACY_URL dan SPENVA_DELETION_URL; profile booleans berubah hanya setelah bukti tersedia. write_profile.py menggabungkan override ke report build. Jangan mengisi true atau identitas rekaan agar validator hijau.

Generate halaman privasi/penghapusan dari aset current memakai `python3 tooling/play/render_legal.py --profile=docs/playstore/publication-profile.json --output=build/legal`; publisher/contact wajib nyata. Review teks dan respons support sebelum hosting. Template docs/privacy/index.html bukan halaman produksi yang sudah aktif.

Jika SPENVA_BILLING_ENDPOINT diaktifkan, gate tambahan berlaku: play_products_verified, billing_server_verified, reporting_verified; paid_ai_confirmed untuk personal AI atau education_privacy_verified untuk opsi edukasi unpaid. Enam produk monthly/yearly berasal dari katalog JSON. Audit tidak men-deploy backend/paid services.

AAB Play wajib permanent upload key, targetAPI36/minAPI24, signed, manifest/ELF/bundle/universal-APK16KB lulus. Upload key dipertahankan; App Signing certificate untuk OAuth diambil dari Console. Jangan upload APK pilot sebagai AAB atau menganggap APK berfungsi berarti Play-distributed OAuth sudah teruji.

Acceptance sebelum publish: update existing install, Google/Drive, camera/gallery/file/denied permissions, microphone, keyboard/font besar, report/PDF, invalid/legacy restore, logout/Back, deletion cloud-failure, Play license purchase/pending/renew/cancel/grace/expiry/refund/restore lintas perangkat bila billing aktif; pre-launch report dan akses reviewer. [DATA_SAFETY](DATA_SAFETY.md), [SUBSCRIPTION](SUBSCRIPTION.md), [VALIDATION](VALIDATION.md).
