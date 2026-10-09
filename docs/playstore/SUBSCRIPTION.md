> Current source status: **0.3.4+19**, 9 October 2026 UTC. See [../SPENVA_CANONICAL_SOURCE.md](../SPENVA_CANONICAL_SOURCE.md) and the current detailed audit. Older version/build statements below are historical evidence and do not verify this patch.

> **Verifikasi +18 selesai:** runtime `7bfd653d6dfe3a893c1c2252a1f345f48f5a9122`; Flutter 134 lulus, backend 46 lulus, validator 5 lulus, suite Play 11 lulus dan integrasi Linux 1 lulus. Signed AAB 75.1 MB lolos pemeriksaan 16 KB. [CI](https://github.com/rama160/Finchat/actions/runs/37464173519), [AAB/APK](https://github.com/rama160/Finchat/actions/runs/37464173519/artifacts/11413279142). Pembelian dan deployment subscription belum aktif. Detail hasil: [VALIDATION.md](VALIDATION.md).

# Subscription baseline 0.3.4+18

Instruksi sumber: SPENVA_SUBSCRIPTION_FINAL_INSTRUCTION.md. Implementasi memakai satu sumber angka `assets/config/subscription_plans.json`. Jalankan `python3 tooling/play/generate_subscription.py` setelah mengubah konfigurasi; CI `--check` menolak Dart/server generated yang berbeda. Enum internal basic/unlimited dipertahankan untuk kompatibilitas; nama pengguna Plus/Max. Application ID, schema/database1, parser, OAuth dan format backup tetap.

| Paket | Bulanan | Tahunan | Voice/bulan | Scan/bulan | AI/bulan |
|---|---:|---:|---:|---:|---:|
| Free | Rp 0 | — | 10 | 5 | 5 |
| Plus | Rp 15.000 | Rp 149.000 | 100 | 100 | 50 |
| Pro | Rp 39.000 | Rp 349.000 | 500 | 500 | 200 |
| Max | Rp 89.000 | Rp 799.000 | 1.500 | 1.500 | 500 |

PRO diberi badge PALING DIREKOMENDASIKAN. Max merupakan produk nyata dengan kuota nyata, tanpa label unlimited. Harga live tetap ProductDetails Google Play. Enam subscription products finchat_plus_monthly/yearly, finchat_pro_monthly/yearly, finchat_max_monthly/yearly. Base plan masing-masing monthly/yearly, auto-renewal1bulan/1tahun. Tidak ada pembayaran eksternal. Produk/config belum live sampai Play Console/server tersedia. Pergantian produk setelah paket sebelumnya berakhir, bukan upgrade prorata. Perubahan tier di ledger membawa penggunaan lama, tidak memberi reset gratis.

## Entitlement dan pengalaman

Semua paket: teks/local parser/transaksi/SQLite/kategori/local learning tanpa batas, laporan dan grafik dasar. Free manual Drive backup, **1 ekspor PDF sukses/bulan** (keputusan implementasi untuk istilah “terbatas”). Paid PDF tanpa batas, backup otomatis dan grafik perbandingan dengan rentang sebelumnya yang sama panjang. Grafik/insight dasar lama tidak dihapus. Pro/Max jawaban cloud terstruktur; Plus/Free jawaban ringkas. Jawaban lokal tidak mengambil kuota AI dan tidak dibatasi tier.

Priority AI: slot concurrency server untuk Pro/Max sampai4, Free/Plus hanya2; bukan jaminan latency/modelprovider. Priority support: laporan in-app menyimpan penanda tier/priority server dan diurutkan per halaman operator, tidak ada SLA atau petugas otomatis. Pelaksana support tetap perlu tersedia sebelum dipasarkan.

Kamera/gallery/attach/file memanggil gate Scan yang sama. Satu gambar/halaman berhasil dibaca memakai1credit meski berisi banyak item. File multipage belum ditambahkan; tidak ada klaim memproses PDF struk multipage. Jika OCR menghasilkan teks lalu review dibatalkan, credit tetap terpakai karena halaman sudah diproses. Gambar gagal terbaca dan gagal sebelum OCR dilepas. Voice satu sesi bukan satu transaksi; banyak transaksi yang tersimpan hanya memakai1Voice. Voice gagal/tanpa ucapan/cancel dilepas. Pertanyaan suara menggunakanVoice; cloudcall mengambilAI secara terpisah. AI gagal direfund server, lokal tetap tersedia. Ekspor PDF canceled sebelum/saat file picker tidak dihitung; share berhasil berarti dialog sistem telah menerima PDF, bukan bukti penerima membacanya.

## Persistensi / batas offline

Kuota produksi diterapkan pada **build Play**, pilot tetap memakai workflow lama. Ledger Durable Object di luar SQLite/backup, identitas SHA256 Google sub divalidasiRS256 server. Fitur metered memerlukan akunGoogle dan koneksi ke server supaya uninstall/restore/pergantianperangkat tidak meresetquota. Teks, laporan dasar, pembelajaran dan data lokal tetap offline. Tidak ada bypass ke kuota lokal ketika server gagal. Setelah logout akun lokal tidak mendapat kuota baru. Setelah instalasi ulang, masuk akunGoogle yang sama dan ledger/purchase server dipulihkan tanpa bergantung pada token diAPK.

Free periode kalender UTC. Paid monthly/yearly punya jendela bulanan berdasarkan startTime Google, tanggal31/leapday diklem, tidak tahunan sekaligus. Pada perpindahan Free ke paid, penggunaan yang masih berjalan dibawa; periode selanjutnya mengikuti anchorbilling tanpa reset tambahan pada batas kalender Free. ACTIVE/CANCELED/GRACE_PERIOD berlaku sampai expiry, EXPIRED menjadiFree; paused/onhold/pending tidak memberi premium. Client tidak dipercaya mengirim tier/limit. Reserve atomik sebelum operasi, settle idempotent; pending setelahcrash/reinstall tetap dihitung sampai akhirperiode. Ledger dipertahankan sampaiakhirperiode+30hari untuk penyalahgunaan/langganan, tidak dihapus oleh restorebackup/penghapusanlokal. Penggunaan lokal pada perangkat yang dimodifikasi/root tidak dapat dibuktikan kriptografis oleh server; hard enforcement AI ada pada server, Voice/OCR/PDF memakai clientgate server.

## Infrastruktur tanpa biaya otomatis

Cloudflare tetap dapat di-deploy pada free plan; tidak ada perubahan plan otomatis. Gemini tidak diaktifkan billed dari kode/CI. **Unpaid Gemini melarang informasi pribadi/sensitif**; raw pertanyaan keuangan, struk dan histori tidak dikirim ke unpaid. PAID_AI_CONFIRMED=false mempertahankan penutupan personalAI. UNPAID_EDUCATION_ENABLED=false default; pemilik dapat mengaktifkan trial edukasi umum yang hanya mengirim enum topic ke server dan fixed prompt budget/emergency/saving, tanpa teks pengguna/riwayat. Server menolak rawmessages pada jalurunpaid. CloudFreequota tidak menjamin layanan tersedia setiap saat. KuotaFreeAI5 disiapkan, bukan janji bahwa AIpersonal aktif.

Untuk personalAI, butuh keputusan eksplisit provider/project sesuai terms; jika billed dipilih, idealnya recurringrevenue>=5×estimasicost sebagai syarat bisnis. Alert bukan spendingcap. KuotaAI tetap melindungi batasuser; tetap perlu limitglobalprovider danmonitorcost. Tidak ada switching gratis-ke-berbayar otomatis.

Monitoring ledger tanpa isi transaksi: total percobaan AI/per paket, usedVoice/Scan/AI/PDF, local_success/cloud_success per jumlah transaksi tersimpan (rasio lokal/cloud dapat dihitung), fallback, ai_error, timeout, rate_limit. Endpoint adminreports menyajikan feedback opsional; admin/usage menampilkan counter per hashakun, periode/status dan persentase transaksi lokal/cloud tanpa token/operationID. Keduanya memakai admin bearer secret. Belum ada dashboardanalytics lintasakun/konversi/churn: perlu operasionalConsole/analytics opt-in, tidak mengirim histori ke thirdparty hanyauntukmonitoring.

## Aktivasi dan pengujian

Deploy server terpisah hanya setelah KV/DO/clientID danserviceaccount tersedia; gatewaypilot tidak diganti. Isi SPENVA_BILLING_ENDPOINT untuk buildPlay, buat6produk danujiPlay-distributed payments/restore/expiry/cancel/grace. Tidak ada produk dibuka hanya dari state purchased client. Pilihan tahunan/Voice/Scan/paywall harus retestHP. Tesunitmock bukan pembayarannyata. Baca LAUNCH.md untuk semua gatepublikasi.
