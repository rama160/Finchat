# Paket dan asumsi biaya

Harga berikut adalah hipotesis awal untuk diuji dalam closed test, bukan bukti bahwa pengguna pasti bersedia membayar. Semua fungsi lokal yang sudah berjalan tetap Free. Nilai berbayar: pertanyaan AI yang lebih bebas berdasarkan ringkasan catatan, setelah pertanyaan yang didukung dicoba secara lokal.

| Tier | Rencana harga bulanan | Kuota AI per periode | Produk Google Play |
| --- | ---: | ---: | --- |
| Free | Rp 0 | 0 | tidak ada |
| Basic | Rp 19.000 | 100 | finchat_basic_monthly |
| Pro | Rp 39.000 | 300 | finchat_pro_monthly |
| Unlimited • fair use | Rp 79.000 | 1.000 | finchat_unlimited_monthly |

Semua produk berbayar memakai base plan **monthly**, auto-renewing satu bulan, Indonesia/IDR. Mulai tanpa trial dan tanpa intro offer supaya harga/kuota jelas. Jangan aktifkan produk sebelum sandbox pembelian, restore, expiry, refund dan account binding lolos. UI menggunakan harga ProductDetails Google Play saat tersedia; harga rencana bukan harga yang boleh ditagihkan di luar Google Play. Pergantian paket dalam versi ini dilakukan setelah paket lama berakhir, bukan proration/in-place upgrade. Pengguna tidak ditawari paket kedua saat paket aktif diketahui.

Kuota tidak rollover. Permintaan AI gagal dikembalikan ke kuota; periksa monitoring refund kuota jika storage sedang gagal. Rate limit 10 permintaan/menit. Satu periode ditentukan expiry pembelian terverifikasi, bukan bulan kalender. Batalkan lewat Play; hapus akun tidak membatalkan pembayaran. Jangan menyebut Unlimited sebagai AI tanpa batas.

## Perhitungan konservatif yang dapat diulang

Model server: Gemini 2.5 Flash-Lite Paid Standard. Batas maksimum per permintaan: 4.096 token input, 768 output, thinking budget 0, tanpa grounding/cache/expensive fallback. Harga resmi 6 Oktober 2026: USD 0,10/1 juta input dan USD 0,40/1 juta output. Asumsi stres kurs **Rp 20.000/USD**, bukan klaim kurs aktual. Biaya AI maksimal per jawaban = (4096×0,10+768×0,40)/1.000.000 × 20.000 = **Rp 14,336**. Gemini countTokens perlu dimonitor; batas ini hanya biaya inference yang terukur, tidak mencakup biaya platform/support/pajak.

| Tier | Pendapatan setelah asumsi fee Play 15% | Biaya AI jika kuota habis | Sisa sebelum pajak, Cloudflare, refund dan dukungan |
| --- | ---: | ---: | ---: |
| Basic | Rp 16.150 | Rp 1.433,60 | Rp 14.716,40 |
| Pro | Rp 33.150 | Rp 4.300,80 | Rp 28.849,20 |
| Unlimited | Rp 67.150 | Rp 14.336 | Rp 52.814 |

Fee resmi subscriptions auto-renewing umumnya 15%; periksa kontrak Console, pajak dan harga regional sebelum final. Harga akhir pelanggan dapat berbeda setelah pajak. Cadangkan biaya tetap, support, chargeback/refund, storage, Google verification request dan pertumbuhan. Satu pengguna gratis tidak memicu biaya AI dari build Play. Jangan menyalakan billed API/Cloudflare plan secara otomatis dari CI. Buat budget alert dan limit provider sebelum membuka penjualan; alert bukan hard spending cap.

## Validasi apakah layak dibayar

Closed test: minta pengguna mencoba Free lebih dahulu, lalu coba AI dengan pembelian uji tanpa tagihan sungguhan. Ukur kualitas jawaban, latensi p50/p95, kuota terpakai, biaya nyata dan alasan membeli/tidak membeli. Wawancara harga tidak sama dengan pembayaran aktual. Setelah produksi terbatas, evaluasi konversi dan pembatalan tanpa mengambil transaksi pribadi sebagai analytics. Jika nilai AI belum kuat, perbaiki kualitas sebelum menaikkan harga atau mengunci fungsi Free. Jangan menjanjikan penghematan uang atau return keuangan tertentu.

Sumber: https://ai.google.dev/gemini-api/docs/pricing ; https://support.google.com/googleplay/android-developer/answer/112622 ; https://support.google.com/googleplay/android-developer/answer/9858738
