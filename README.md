# FinChat

FinChat adalah aplikasi Android personal finance assistant berbasis Flutter dengan pendekatan **offline-first** dan chat-first.

<<<<<<< HEAD
## Current status

- Phase 1–9 technical baselines: completed.
- Phase 9 GitHub Actions: reported successful by project owner.
- Phase 10: Update & Release + documentation reconciliation.
- Phase 11: QA & end-to-end integration — next after Phase 10 CI passes.

See `docs/ROADMAP_AUDIT.md` for the distinction between technical baselines and remaining product requirements.

## Development model

Repository ini dirancang agar pengguna tidak perlu memasang Flutter secara lokal. GitHub Actions adalah environment verifikasi utama:

1. Push kode ke GitHub.
2. Actions memasang Flutter stable.
3. Actions menjalankan `flutter pub get`, `flutter analyze`, dan `flutter test`.
4. Workflow Android membuat folder `android/` jika belum ada.
5. Actions menjalankan `flutter build apk --release`.
6. APK tersedia sebagai artifact/release asset.

## Upload otomatis dari Windows

Jalankan `UPLOAD_TO_GITHUB.bat` dari root project. Script tidak melakukan force push dan berhenti bila merge conflict perlu keputusan manual.

## Update aplikasi

Settings memiliki update checker yang membaca latest published GitHub Release dari repository `rama160/Finchat`. Jika versi remote lebih tinggi, pengguna dapat membuka halaman release untuk mengunduh APK. Self-install/Play Store distribution belum dianggap selesai dan dicatat di roadmap.

## Data architecture

SQLite adalah local source of truth. Transaksi diakses melalui repository. Category corrections disimpan per user dan dicatat dalam history. AI/OCR tidak boleh menulis database secara langsung.

## Dokumen utama

=======
## Cara kerja pengembangan

Repository ini dirancang agar pengguna **tidak perlu memasang Flutter secara lokal**. Verifikasi utama dilakukan oleh GitHub Actions:

1. Push kode ke GitHub.
2. GitHub Actions memasang Flutter stable.
3. Actions menjalankan `flutter pub get`, `flutter analyze`, dan `flutter test`.
4. Workflow Android membuat folder `android/` otomatis jika belum ada.
5. Actions menjalankan `flutter build apk --release`.
6. APK tersedia sebagai artifact workflow.

## Upload otomatis dari Windows

Jalankan `UPLOAD_TO_GITHUB.bat` dari root project. Script:
- membuat Git repository jika belum ada;
- memakai remote `origin` yang sudah ada atau meminta URL sekali;
- commit perubahan;
- mengambil remote `main`;
- menangani history berbeda dengan merge aman;
- berhenti jika merge conflict;
- **tidak pernah force push**;
- push ke `main`.

## Dokumen utama

Baca berurutan:
>>>>>>> origin/main
1. `Ai start here.md`
2. `docs/FINCHAT_MASTER_CONTEXT.md`
3. `docs/PRD.md`
4. `docs/ARCHITECTURE.md`
5. `docs/PHASES.md`
6. `docs/AI_CONTRACT.md`
<<<<<<< HEAD
7. `docs/ROADMAP_AUDIT.md`
8. `docs/IMPLEMENTATION_STATUS.md`
9. `CHANGELOG.md`
=======
7. `docs/IMPLEMENTATION_STATUS.md`
8. `CHANGELOG.md`

## Status

Phase 2 — Flutter Foundation. Foundation UI dan CI sudah disiapkan. Persistent secure session, database lokal, migration, repository nyata, dan verifikasi Android masih menjadi pekerjaan berikutnya.

## Local Data Architecture

FinChat uses SQLite as its offline-first local source of truth. Application code accesses transactions and category learning through repositories. Category corrections are persisted per user and recorded in category history. AI is a fallback and must not write directly to SQLite.
>>>>>>> origin/main
