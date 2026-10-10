# Langganan dan kuota

**Versi sumber: 0.3.5+20**

Katalog, harga, produk dan kuota hanya berasal dari [subscription_plans.json](../../assets/config/subscription_plans.json). [PLANS](PLANS.md) adalah tabel generated; bukan salinan angka manual. Nama publik Free/Plus/Pro/Max; enum internal basic/unlimited tetap kompatibel. Google Play ProductDetails menentukan harga yang benar-benar dibayar pengguna.

Katalog tampil, tetapi pembelian/server belum live. Digital subscriptions hanya Google Play Billing; tidak ada QRIS/GoPay/external checkout. Enam produk bulanan/tahunan ada di JSON; perubahan paket ditawarkan setelah paket sebelumnya berakhir, tanpa klaim prorata. Annual mengisi kuota bulanan, bukan seluruh jatah setahun sekaligus.

## Entitlement dan operasi

Server memverifikasi Google ID token, fixed application ID, subscriptionsv2, purchase token, account hash, product/base plan, start/expiry/state. Client status purchased tidak memberi paket. ACTIVE/CANCELED/GRACE_PERIOD berlaku sampai expiry; expired/paused/on-hold/pending tidak memberi premium. Paket dan ledger dapat dipulihkan melalui akun sama setelah reinstall.

Voice dihitung per sesi sukses, bukan per transaksi. OCR dihitung per gambar berhasil dibaca; cancellation setelah OCR berhasil tetap memakai satu kredit. Kamera/galeri/attach/file berbagi Scan; tidak ada dukungan struk PDF multipage. AI gagal direfund oleh server. Free PDF satu export sukses/bulan; cancel file picker tidak dihitung, share sukses berarti sistem menerima PDF, bukan penerima membaca. Teks/parser/kategori/learning/transaksi dan laporan dasar tidak dibatasi. Jawaban lokal tidak mengambil kuota AI.

Paid memberikan PDF tanpa batas, automatic backup dan comparison premium. Pro/Max memperoleh format analisis dan concurrency prioritas, bukan jaminan latency/provider. Feedback priority memerlukan operator nyata, tidak mengandung SLA otomatis.

## Ledger dan koneksi

Play metered features memerlukan akun Google dan koneksi verifikasi. Ledger DO per account di luar SQLite/backup; logout/reinstall/deletion lokal/restore tidak meresetnya. Reserve atomik dan settle idempotent. Reservation ditinggal saat crash tetap dihitung hingga periode berakhir. Free memakai bulan kalender UTC; paid memakai monthly window dari startTime, termasuk annual; tanggal31/leap day diklem. Perubahan tier membawa penggunaan yang masih aktif.

Pencatatan teks dan laporan lokal tetap berjalan saat layanan server tidak tersedia. Pada build Play yang endpoint-nya belum aktif, Voice/Scan/PDF/AI belum dapat diverifikasi; aplikasi harus memberi pesan yang sesuai. Pilot sideload mempertahankan perilaku sebelum gate Play. Voice/OCR/PDF client gates bukan perlindungan terhadap modifikasi/root; AI dibatasi server.

## AI dan privasi

Personal AI default ditutup dengan PAID_AI_CONFIRMED=false. UNPAID_EDUCATION_ENABLED=false; bila secara eksplisit diaktifkan, hanya fixed topic tanpa raw question/financial data. Provider/project harus sesuai ketentuan pemrosesan; tidak ada aktivasi biaya otomatis. Consent18+ sebelum cloud. Data/retensi ada pada [DATA_SAFETY](DATA_SAFETY.md) dan aset privacy current.

Feedback tersimpan30 hari, dengan Q/A hanya jika checkbox dipilih. Ledger pseudonim sampai akhir periode ditambah30 hari, tanpa isi transaksi/pertanyaan. Monitoring per account mencatat attempted AI, resource usage, local/cloud completions, timeout/error/rate limit; bukan dashboard conversion/churn yang sudah selesai. Account deletion tidak membatalkan Play subscription.

## Aktivasi

Server sumber tersedia di server/play-billing, belum di-deploy. Perlu DO/KV, Google OAuth audience, Publisher service account/API, product/base plans, endpoint dan acceptance Play license billing. Tidak ada RTDN; entitlement diverifikasi on-demand. Uji pending/ack, renew/cancel/grace/expiry/refund, account mismatch, restore/device switch, quota paralel, refund failure, retention/deletion dan plugin HP. [LAUNCH](LAUNCH.md) memuat gate publikasi; [VALIDATION](VALIDATION.md) memuat hasil CI nyata.
