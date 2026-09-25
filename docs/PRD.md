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
