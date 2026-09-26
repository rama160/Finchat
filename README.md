# FinChat

FinChat adalah aplikasi Android personal finance assistant berbasis Flutter dengan pendekatan **offline-first** dan chat-first.

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
1. `Ai start here.md`
2. `docs/FINCHAT_MASTER_CONTEXT.md`
3. `docs/PRD.md`
4. `docs/ARCHITECTURE.md`
5. `docs/PHASES.md`
6. `docs/AI_CONTRACT.md`
7. `docs/IMPLEMENTATION_STATUS.md`
8. `CHANGELOG.md`

## Status

Phase 2 — Flutter Foundation. Foundation UI dan CI sudah disiapkan. Persistent secure session, database lokal, migration, repository nyata, dan verifikasi Android masih menjadi pekerjaan berikutnya.

## Local Data Architecture

FinChat uses SQLite as its offline-first local source of truth. Application code accesses transactions and category learning through repositories. Category corrections are persisted per user and recorded in category history. AI is a fallback and must not write directly to SQLite.
