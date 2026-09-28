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
