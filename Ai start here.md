# AI START HERE — FINCHAT

Jika AI baru melanjutkan project ini, **jangan meminta user menjelaskan ulang project** sebelum membaca dokumen berikut.

## Urutan baca
1. `docs/FINCHAT_MASTER_CONTEXT.md`
2. `docs/PRD.md`
3. `docs/ARCHITECTURE.md`
4. `docs/PHASES.md`
5. `docs/AI_CONTRACT.md`
6. `docs/IMPLEMENTATION_STATUS.md`
7. `CHANGELOG.md`
8. source code yang benar-benar ada di repository

## Aturan melanjutkan
- Tentukan phase aktif dari `IMPLEMENTATION_STATUS.md`.
- Cari pekerjaan pertama yang belum selesai.
- Periksa source code aktual sebelum mengubah apa pun.
- Jangan menulis ulang bagian yang sudah bekerja tanpa alasan.
- Jalankan test/analyze melalui GitHub Actions jika Flutter tidak tersedia lokal.
- Setiap perubahan bermakna wajib masuk ke `CHANGELOG.md` dan `IMPLEMENTATION_STATUS.md`.
- Jangan membuat AI langsung menulis database.
- Jangan menghilangkan data user ketika parser/AI gagal.
- Jangan melakukan force push otomatis.

## Kondisi package ini
Phase aktif: **Phase 2 — Flutter Foundation**.

Workflow canonical: GitHub Actions. Folder Android boleh belum ada di source; workflow `build_android.yml` akan membuat platform Android dengan `flutter create --platforms=android` sebelum build jika folder tersebut belum tersedia.

## Tugas berikutnya
1. Ganti session in-memory dengan secure persistent storage.
2. Tambahkan local database dan migration foundation.
3. Implementasikan repository transaksi nyata.
4. Perkuat navigation/session lifecycle.
5. Tambahkan unit/widget/integration tests.
6. Pastikan GitHub Actions analyze, test, dan APK build berhasil.

## Handoff
Pada akhir pekerjaan tulis di `IMPLEMENTATION_STATUS.md`: phase, completed, in-progress, exact next task, blockers, tests, changed files, dan decisions.
