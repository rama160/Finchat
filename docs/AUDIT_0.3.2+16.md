## Spenva 0.3.2+16 — perbaikan hasil uji HP (6 Oktober 2026)

- Perbaikan formatter digit: tidak lagi menyisipkan titik di awal angka 3/6/9 digit. Semua tampilan, jawaban AI/lokal dan PDF memakai `Rp 567.765`; jawaban provider seperti `Rp .567.678` dinormalisasi.
- Logo mark/header/sign in/launcher menggunakan outline bentuk dan wordmark dari referensi pengguna; tidak menggunakan font pengganti atau gambar pratinjau penuh. Aset terpisah dibundel offline, termasuk foreground adaptive Android.
- Input kosong benar-benar kosong (tanpa ikon dompet, Halo/email atau petunjuk lama). Header sapaan lokal tetap. Composer tidak menggambar underline composing IME, tetap menjaga range/fokus/keyboard; koreksi otomatis/saran/ejaan dimatikan pada kotak input.
- Kartu pemasukan/pengeluaran memakai lebar penuh dan tinggi mengikuti isi, tanpa ellipsis. Selisih periode menjadi Saldo. Tombol Ekspor PDF bawah dihapus; ikon download atas tetap membuka simpan ke perangkat/bagikan PDF.
- Pertanyaan tanpa periode eksplisit langsung dijawab tanpa awalan Semua tanggal. Tanggal/rentang eksplisit tetap dipakai untuk data dan label jawaban.
- Kategori standar memakai nama umum (Makanan dan minuman, Tagihan, Kesehatan, Transportasi, Kebutuhan rumah tangga, Hiburan, Lainnya); ID dan data lama tidak diubah. Kategori impor per-item disembunyikan dari pilihan, kategori buatan pengguna dan pembelajaran tetap dipertahankan.
- Setelah restore parsial, repository kategori menambahkan standar yang hilang dengan insert-ignore tanpa mengganti data/kategori yang sudah ada. Ini menutup kegagalan foreign-key saat gaji pertama setelah backup yang tidak memuat kategori gaji. Input gaji/upah tetap pemasukan; nominal gaji tanpa Rp seperti `gaji 5000000` kini diproses lokal.
- Application ID, database/schema, autentikasi, gateway, format backup, MoneyAmountParser, repository transaksi dan tiga workflow asli dipertahankan. Versi APK/Pengaturan 0.3.2+16.
- Verifikasi GitHub analyze/test/build sedang dijalankan. Jangan menganggap patch ini sudah lulus sampai bukti CI berikut ditambahkan. Pengujian IME/mikrofon dan pemasangan APK masih perlu di HP.

