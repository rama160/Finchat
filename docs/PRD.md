## Device follow-up — 0.3.2+12 (5 Oktober 2026)

- Capture teks/suara/struk kini menggunakan parser dan mapping lokal tanpa HTTP AI per item; mapping dibaca sekali per input. AI Q&A tetap tersedia sebagai fallback.
- Normalisasi nominal suara mendukung "nasi sepuluh ribu" serta "nasi 10 ribu".
- Provider AI menggunakan akun Google hasil authenticate yang diingat coordinator sebelum mencoba restorasi lightweight; JWT kedaluwarsa tidak digunakan dan cache dibersihkan saat sign-out.
- Pertanyaan nota dengan kata kunci menghitung dan merinci hanya deskripsi yang cocok; saran hemat dasar dapat dijawab lokal. Kendala yang belum didukung tidak diam-diam dijawab sebagai total keseluruhan.
- Input default hari ini; midnight/resume mengatur ulang tampilan harian dan Q&A tanpa menghapus data SQLite. Pertanyaan dan jawaban memakai bubble terpisah.
- Laporan mempertahankan total berdasarkan periode dan pie chart; bagian jumlah/detail transaksi di bawah chart diganti grafik pengeluaran harian. Hari tanpa pengeluaran bernilai nol; rentang/bulan mengikuti filter.
- Preprocessing gambar dipindahkan ke isolate. Error OCR tidak menampilkan stack trace di layar; cleanup recognizer tidak menimpa hasil. Keep rules native ML Kit/component registrar diperkuat untuk release.
- Tidak ada perubahan schema, database lifecycle, Drive backup, endpoint Gateway, secrets, atau tiga workflow asli. Perubahan login terbatas pada penyimpanan akun aktif, bukan alur pemilihan akun.
- Status: patch disiapkan; CI terbaru harus diverifikasi. OCR native dan AI live perlu tes perangkat. Screenshot stack trace terobfuscate tidak cukup untuk memastikan akar NPE; keep rules adalah mitigasi release, bukan klaim hasil perangkat.

# FinChat PRD

## Tujuan
Menyediakan aplikasi keuangan pribadi yang mudah digunakan, offline-first, dengan chat sebagai cara utama memasukkan dan menanyakan data keuangan.

## Functional requirements
- Login dan session persistence.
- Input transaksi melalui text, voice, attachment, camera.
- Satu input dapat menghasilkan beberapa transaksi.
- Edit tanggal, nominal, tipe, dan kategori.
- Parser lokal sebelum AI.
- AI fallback hanya saat parser lokal tidak cukup.
- Pembelajaran kategori dari koreksi user.
- Receipt preprocessing sebelum OCR.
- Reports income/expense dan detail transaksi.
- Pie chart expense per category dan jumlah transaksi.
- Chart/insight tambahan.
- Settings.
- Local storage.
- Offline backup/restore.
- Automatic Google Drive backup/restore setelah email dikonfigurasi.
- Update aplikasi tanpa kehilangan data.
- GitHub Actions untuk analyze/test/build.

## Acceptance baseline Phase 2
- Flutter project dapat dianalisis dan dites oleh GitHub Actions.
- Build Android tidak membutuhkan Flutter di komputer user.
- Uploader Windows tidak menghapus history remote.
- Divergent initial history ditangani dengan merge aman atau berhenti pada conflict.

## Phase 10 acceptance

- Session remains available after application restart unless the user logs out or the session is invalid.
- Settings exposes the application version and an update-check action.
- Update checking uses a provider abstraction and does not write to the local database.
- A newer GitHub Release can be opened by the user for download.
- Update checks do not silently install or overwrite application data.

## Product-completion rule

A technical phase may be marked as a baseline when its contracts/services/tests pass, but the original product acceptance criteria remain open until the corresponding UI/device/end-to-end behavior is implemented. See `docs/ROADMAP_AUDIT.md`.


## Phase 12 production-hardening acceptance
- Transaction writes are validated and multi-transaction saves are atomic.
- Invalid backup structures are rejected before destructive restore.
- AI configuration and network behavior fail safely.
- UI operation failures are surfaced without crashing the application.
- Release metadata is versioned without embedding signing credentials.
- Final acceptance requires CI plus one complete Android device QA cycle.

## Perbaikan produk 5 Oktober 2026

- Input bersama untuk transaksi pengeluaran/pemasukan dan pertanyaan lokal/AI; jawaban tampil di chat.
- Composer putih membulat dengan emoji, attachment, kamera langsung dan tombol biru mic/send/stop.
- Edit transaksi melalui swipe kanan, hapus melalui swipe kiri; ikon edit/hapus di row dihilangkan.
- Satu centang membuktikan penyimpanan SQLite; dua centang setelah backup Google Drive berhasil untuk versi transaksi tersebut.
- Laporan berada di bottom navigation dengan income/expense/saldo/count, pie kategori, detail, insight dan PDF.
- Filter hijau memiliki panah dan dropdown tanggal, rentang, bulan/tahun. Rentang satu hari menjadi tanggal; satu bulan lengkap menjadi bulan secara otomatis.
- System Back kembali ke submenu/halaman sebelumnya; dari tab Laporan kembali ke Input.
- Keberhasilan AI terdeploy dan plugin Android harus dikonfirmasi melalui CI dan QA perangkat, sesuai `AUDIT_0.3.2+11.md`.
