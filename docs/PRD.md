# Spesifikasi produk Spenva

**Versi sumber: 0.3.5+20**

Spenva adalah pencatat keuangan pribadi Android dengan interaksi chat dan sumber data lokal. Bukan bank, layanan transfer, pinjaman atau trading.

| Fungsi | Perilaku yang disyaratkan dan diimplementasikan | Acceptance |
|---|---|---|
| Masuk | Google atau mode offline; email lokal lama membuka profil lama; sesi bertahan setelah restart | SessionManager/unit + uji OAuth signing HP |
| Teks | Contoh `nasi 10 ribu dan bensin 50k`, `gaji 5000000`; local parsing dan learned category; batch atomik | Parser, entry-flow, database dan widget tests |
| Suara | id_ID; partial/final/cumulative disatukan, tanpa transaksi duplikat; normalisasi angka/kata; cancel tidak menyimpan | Fake provider tests + speech HP |
| Kamera/lampiran | Kamera/galeri/file JPG/JPEG/PNG/WEBP; preprocessing; ML Kit lokal; review dan koreksi sebelum save | OCR/parser/review tests + izin/plugin HP |
| Edit/hapus | Swipe kartu; dialog edit kategori/nominal/deskripsi; konfirmasi hapus; learning tersimpan | Repository/learning/widget tests |
| Tanya keuangan | Pertanyaan di chat; periode dari pertanyaan; total/saldo/kategori/kata kunci lokal; AI hanya untuk yang belum terjawab | QA/period/intent tests; jaringan AI live terpisah |
| Input harian | Timeline transaksi dan jawaban hari aktif; reset tampilan pada pergantian hari tanpa delete riwayat | Daily reset/timeline tests |
| Laporan | Tanggal tunggal/rentang/bulan/tahun; periode sama untuk ringkasan/detail/pie/grafik harian/insight/PDF | Period/report/domain/widget + native integration |
| PDF | Simpan file atau bagikan; data periode yang dipilih; rupiah konsisten | PDF bytes tests + save/share HP |
| Backup | UTF-8 whole-database; enam tabel snapshot atomik; validasi sebelum delete; rollback; backup legacy dimapping | Backup/validation/acknowledgement tests |
| Drive | Manual consent; background silent; failure tidak memblokir input; acknowledgement hanya versi yang diupload | Auth/cloud tests + Drive HP |
| Navigasi | Back submenu kembali ke layar sebelumnya; Back Laporan kembali Input; logout menghapus route profil lama | Navigation tests + Android system Back |
| Pembaruan | Pilot membaca GitHub release; build number dibandingkan; Play membuka store; tidak install otomatis | Version comparison tests + release metadata checks |
| Privasi | Delete akun/data eksplisit; logout hanya clear session; cloud failure mencegah delete lokal berikutnya | Privacy/source checks + online acceptance |

## Distribusi dan paket

Pilot mempertahankan fungsi lokal dan Gateway lama. Play memakai endpoint subscription/kuota terpisah; Voice/Scan/PDF/AI memerlukan akun Google dan server verifikasi, termasuk Free. Jika endpoint belum aktif, tampilkan ketidaktersediaan layanan, jangan menjanjikan fitur metered berjalan. Teks, learning, laporan dasar dan pertanyaan lokal tetap offline. Harga/kuota: [PLANS](playstore/PLANS.md); mekanisme: [SUBSCRIPTION](playstore/SUBSCRIPTION.md).

## UX dan data

Logo/font offline; sapaan jam perangkat dan nama pengguna; composer putih membulat dengan emoji/lampiran/kamera/mikrofon/kirim; nominal tidak dipotong pada teks besar. User ID tetap email normalized untuk data lama; token rahasia tidak masuk database/backup. Application ID dan schema tidak diganti. Backup dapat berisi profil lain: pengguna wajib melihat konfirmasi sebelum restore.

## Definisi selesai

Analyze/test/regression dan build signed lulus pada SHA saat ini, dokumentasi sesuai implementasi, source main sesuai pubspec, tidak ada dead route/konfigurasi manual kedua. Uji real-device untuk OAuth/speech/OCR/picker/Drive/IME, lifecycle billing serta persyaratan Play dicatat terpisah dan harus selesai sebelum klaim production-ready.
