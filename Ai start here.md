# AI START HERE — FINCHAT

> **Dokumen handoff utama untuk AI yang melanjutkan project FinChat.**
>
> Tujuan file ini adalah membuat AI dapat melanjutkan project berdasarkan repository aktual, dokumentasi, test, dan riwayat perubahan **tanpa bergantung pada chat sebelumnya** serta **tanpa merusak kode yang sudah terbukti berjalan**.

---

## 1. ATURAN PALING PENTING

### 1.1 Jangan mengubah kode yang sudah berjalan tanpa alasan teknis yang jelas

Sebelum mengubah file apa pun:

1. Baca dokumentasi project.
2. Periksa source code aktual.
3. Periksa test yang terkait.
4. Periksa `CHANGELOG.md` dan status phase.
5. Identifikasi fungsi yang sudah berjalan.
6. Tentukan file minimum yang benar-benar perlu diubah.
7. Jangan melakukan refactor besar hanya untuk merapikan kode.
8. Jangan mengganti arsitektur yang sudah berjalan kecuali requirement memang membutuhkan dan dampaknya sudah dijelaskan.
9. Jangan menghapus fitur existing hanya karena fitur tersebut belum sempurna.
10. Jika sebuah bagian sudah bekerja, **pertahankan behavior-nya** selama tidak bertentangan dengan requirement baru.

### 1.2 Source code aktual adalah sumber kebenaran untuk implementasi

Jika dokumentasi berbeda dengan kode:

- jangan langsung mengubah kode agar sesuai dokumentasi;
- bandingkan kode, test, changelog, dan requirement;
- tentukan behavior aktual yang memang dimaksud;
- dokumentasikan ketidaksesuaian;
- perbaiki dokumentasi jika kode yang berjalan memang benar;
- ubah kode hanya jika requirement/product acceptance memang mengharuskannya.

### 1.3 Jangan menganggap phase selesai hanya karena test lulus

Bedakan:

- **Technical baseline** = service/contract/test sudah tersedia.
- **End-to-end product completion** = UI, device behavior, permission, data flow, dan acceptance user sudah benar-benar berjalan.

`flutter analyze` dan `flutter test` tidak cukup untuk menyatakan sebuah fitur produk selesai.

---

# 2. KONDISI REPOSITORY SAAT HANDOFF

## Identitas project

FinChat adalah aplikasi Android personal finance assistant berbasis Flutter dengan pendekatan:

- chat-first;
- offline-first;
- local database sebagai source of truth;
- parser lokal sebelum AI;
- AI sebagai fallback/supporting intelligence.

## Git baseline

Repository saat package ini dibuat:

- Branch: `main`
- HEAD: `3d46f74`
- Commit: `phase 11.1.2 fixed`
- Remote branch: `origin/main`
- Working tree pada package handoff bersih.

**Jangan melakukan force push.**

## Status phase

- Phase 1–9: technical baseline tersedia.
- Phase 10: Update & Release selesai secara implementasi dan dilaporkan berhasil diverifikasi oleh project owner.
- Phase 11.1: transaction end-to-end vertical slice sudah diimplementasikan.
- Phase 11.1.1: immediate transaction save + edit/delete gesture sudah diimplementasikan.
- Phase 11.1.2: analyzer fixes pada `chat_screen.dart` sudah diterapkan.
- **Current verification state:** perubahan Phase 11.1.2 masih perlu diverifikasi melalui GitHub Actions setelah push.

### Verifikasi canonical

Environment utama project adalah GitHub Actions.

Urutan verifikasi:

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`
4. `flutter build apk --release`

Jangan menyatakan build production berhasil hanya berdasarkan source inspection.

---

# 3. DOKUMEN YANG WAJIB DIBACA SEBELUM BEKERJA

Baca dengan urutan berikut:

1. `Ai start here.md`
2. `docs/FINCHAT_MASTER_CONTEXT.md`
3. `docs/PRD.md`
4. `docs/ARCHITECTURE.md`
5. `docs/PHASES.md`
6. `docs/AI_CONTRACT.md`
7. `docs/ROADMAP_AUDIT.md`
8. `docs/IMPLEMENTATION_STATUS.md`
9. `CHANGELOG.md`
10. source code yang terkait pekerjaan
11. test yang terkait pekerjaan

Jika requirement atau behavior belum jelas, **jangan menebak**. Cari evidence dari repository terlebih dahulu.

---

# 4. HIERARKI SUMBER KEBENARAN

Gunakan prioritas berikut:

1. Requirement user yang eksplisit dan terbaru.
2. PRD/acceptance criteria yang berlaku.
3. Architecture dan AI contract.
4. Source code aktual.
5. Test aktual.
6. Implementation status.
7. Changelog/history.

Jika ditemukan konflik, jangan menyembunyikannya. Catat konflik dan selesaikan dengan perubahan sekecil mungkin.

---

# 5. ARSITEKTUR YANG TIDAK BOLEH DILANGGAR

## Layer

1. Presentation
2. Application
3. Domain
4. Data

Supporting services:

- OCR
- image preprocessing
- AI
- speech
- PDF
- backup
- sync
- update

## Aturan data

- SQLite adalah local source of truth.
- Repository menjadi penghubung persistence.
- Presentation tidak boleh menulis SQLite secara langsung.
- AI tidak boleh menulis database secara langsung.
- OCR tidak menjadi source of truth transaksi.
- OCR menghasilkan data mentah yang harus divalidasi.
- Schema database tidak boleh berubah tanpa migration.
- Penghapusan transaksi menggunakan soft-delete.
- Google Drive hanya backup/sync, bukan primary database.

---

# 6. PIPELINE TRANSAKSI

Pipeline utama:

`Input → normalize → local parser → category resolution → validation → AI fallback bila diperlukan → validation → repository → SQLite`

Prioritas kategori:

1. Koreksi user.
2. Mapping lokal yang dipelajari.
3. Local rules.
4. Context/history.
5. AI.
6. Fallback `lainnya`/safe handling.

AI tidak boleh diam-diam mengganti kategori yang sudah dikonfirmasi user.

---

# 7. BEHAVIOR TRANSAKSI YANG SUDAH BERJALAN

Implementasi aktual `lib/presentation/screens/chat_screen.dart` saat handoff:

1. User memasukkan teks transaksi.
2. `TransactionIntelligenceService` memproses input.
3. Local parser berjalan terlebih dahulu.
4. Multiple transaction dapat dihasilkan dari satu input.
5. Hasil yang berhasil diproses **langsung disimpan ke SQLite**.
6. Setelah tersimpan, transaksi ditampilkan pada daftar.
7. Setiap transaksi dapat:
   - Edit melalui tombol Edit.
   - Delete melalui tombol Delete.
   - Swipe kanan untuk Edit.
   - Swipe kiri untuk Delete.
8. Edit dapat mengubah:
   - description;
   - amount;
   - type;
   - category;
   - date.
9. Koreksi kategori dicatat melalui `CategoryLearningService`.

Contoh baseline:

`Beli nasi 25rb dan bensin 50k`

dapat menghasilkan dua transaksi dan menyimpannya.

### PENTING

Jangan mengembalikan flow text transaction ke model:

`input → review draft → Save`

kecuali ada requirement baru yang secara eksplisit meminta perubahan tersebut.

Untuk text transaction saat ini, behavior yang harus dipertahankan adalah:

`input → parse/intelligence → immediate save → edit/delete setelah tersimpan`

Flow receipt/OCR atau voice **boleh memiliki review step tersendiri** jika confidence/extraction membutuhkan verifikasi user.

---

# 8. KETIDAKSESUAIAN DOKUMENTASI YANG HARUS DIPERHATIKAN

Pada repository handoff ini terdapat dokumentasi lama yang masih menggunakan istilah:

`editable review draft → persistence`

Sementara implementasi aktual `chat_screen.dart` sudah menggunakan:

`immediate save → edit/delete`

AI yang melanjutkan project harus memperlakukan source code aktual + changelog Phase 11.1.1 sebagai baseline behavior, kemudian menyelaraskan dokumentasi yang masih tertinggal.

Jangan mengubah behavior yang sudah berjalan hanya untuk membuatnya cocok dengan dokumentasi lama.

---

# 9. ATURAN PERUBAHAN KODE

Setiap pekerjaan harus mengikuti prosedur:

## Step 1 — Definisikan pekerjaan

Tulis:

- masalah;
- requirement;
- expected behavior;
- file yang kemungkinan terdampak;
- risiko terhadap fitur existing.

## Step 2 — Inspect

Periksa:

- source code;
- dependency;
- interface/contract;
- test;
- call site;
- database schema bila relevan;
- dokumentasi terkait.

## Step 3 — Buat perubahan minimum

Prinsip:

- smallest safe change;
- jangan rewrite file yang tidak relevan;
- jangan rename API tanpa alasan;
- jangan menghapus code existing tanpa replacement yang jelas;
- jangan mengubah schema bila tidak diperlukan.

## Step 4 — Test

Tambahkan/perbarui test untuk behavior yang berubah.

Minimal:

- unit test untuk logic;
- integration/service test jika data flow berubah;
- widget test jika UI behavior berubah;
- GitHub Actions untuk analyze/test/build.

## Step 5 — Dokumentasikan

Setiap pekerjaan bermakna harus memperbarui dokumentasi yang relevan.

## Step 6 — Handoff

Setelah pekerjaan selesai, update status dan next task sehingga AI berikutnya dapat melanjutkan tanpa menebak.

---

# 10. ATURAN UPDATE DOKUMENTASI

## Prinsip utama

**Kode yang berubah harus memiliki dokumentasi yang mengikuti perubahan.**

Jangan hanya mengubah source code lalu meninggalkan documentation state lama.

### Setiap pekerjaan bermakna WAJIB memeriksa dan memperbarui:

- `Ai start here.md`
- `docs/IMPLEMENTATION_STATUS.md`
- `CHANGELOG.md`

### Perbarui jika relevan:

- `README.md`
- `docs/FINCHAT_MASTER_CONTEXT.md`
- `docs/PRD.md`
- `docs/ARCHITECTURE.md`
- `docs/PHASES.md`
- `docs/AI_CONTRACT.md`
- `docs/ROADMAP_AUDIT.md`
- test terkait
- release/update documentation jika release behavior berubah

### Penting

"Setiap file selalu diupdate" **bukan berarti semua source code harus disentuh pada setiap pekerjaan**.

Yang wajib adalah:

- jangan mengubah file yang tidak diperlukan;
- jangan membuat perubahan palsu hanya agar timestamp/file terlihat berubah;
- setiap file yang terdampak harus benar-benar diperbarui;
- tiga handoff files utama (`Ai start here.md`, `IMPLEMENTATION_STATUS.md`, `CHANGELOG.md`) harus tetap mencerminkan keadaan repository setelah pekerjaan bermakna.

Ini menjaga project aman dari perubahan tidak perlu.

---

# 11. CHANGELOG WAJIB

Setiap perubahan bermakna harus memiliki entry di `CHANGELOG.md` dengan:

- phase/version;
- tanggal;
- previous behavior/problem;
- exact change;
- reason;
- impacted components/files;
- migration/data impact;
- tests;
- verification result;
- current status;
- known carry-over.

Jangan menulis:

> "Updated chat screen."

Tulis secara spesifik apa yang berubah dan dampaknya.

---

# 12. IMPLEMENTATION STATUS WAJIB

`docs/IMPLEMENTATION_STATUS.md` harus selalu menunjukkan:

- current phase;
- completed implementation;
- verification state;
- known carry-over;
- next exact task;
- documentation state.

Jika sebuah fitur hanya selesai secara teknis tetapi belum end-to-end, jangan beri status "complete" tanpa keterangan.

---

# 13. AI CONTRACT

AI adalah supporting intelligence, bukan source of truth.

AI:

- tidak boleh menulis database langsung;
- tidak boleh mengarang amount;
- tidak boleh mengarang date;
- tidak boleh mengarang total;
- tidak boleh membuat transaksi fiktif;
- tidak boleh bypass validation;
- tidak boleh mengganti kategori user secara diam-diam;
- tidak boleh overwrite confirmed transaction.

Jika AI gagal:

- pertahankan input;
- jangan hilangkan data;
- izinkan manual correction;
- gunakan safe fallback.

Local parser selalu dicoba sebelum AI fallback.

---

# 14. DATABASE SAFETY

Sebelum mengubah database:

1. baca `lib/data/local/database_schema.dart`;
2. baca `lib/data/local/finchat_database.dart`;
3. cek repository yang memakai tabel terkait;
4. cek test;
5. tentukan apakah migration diperlukan.

Jika schema berubah:

- increment schema version;
- buat migration non-destructive;
- test upgrade database lama;
- test backup;
- test restore;
- dokumentasikan migration di changelog.

**Tidak boleh menghapus database user untuk menyelesaikan bug.**

---

# 15. JIKA MENAMBAHKAN FITUR BARU

Gunakan pola:

`Requirement → Design → Existing code inspection → Minimal implementation → Test → Documentation → CI → Handoff`

Sebelum coding, tentukan apakah fitur tersebut:

- feature baru;
- bug fix;
- UI improvement;
- refactor;
- architecture change;
- schema change;
- documentation-only change.

Jika hanya documentation-only, jangan mengubah source code.

---

# 16. JIKA USER MEMINTA PERUBAHAN PADA FITUR EXISTING

Sebelum mengubah:

1. tunjukkan behavior existing yang akan dipertahankan;
2. jelaskan behavior baru;
3. identifikasi risiko;
4. ubah hanya bagian yang diperlukan;
5. pertahankan API/data compatibility jika memungkinkan;
6. update tests;
7. update documentation.

Jangan melakukan refactor besar sebagai bagian dari perubahan kecil.

---

# 17. TESTING RULE

Setiap perubahan behavior harus mempunyai evidence.

Gunakan:

### Logic
`flutter test`

### Static analysis
`flutter analyze`

### Android release
`flutter build apk --release`

### Product/device
Manual/device acceptance bila diperlukan.

Status harus dibedakan:

- `Implemented`
- `Tested locally`
- `CI verified`
- `Device verified`
- `Product accepted`

Jangan menyamakan semuanya.

---

# 18. CURRENT PRODUCT GAPS

Gap yang masih tercatat dari roadmap:

### Transaction
- Full product-level transaction UX masih perlu disempurnakan.
- Camera/attachment transaction input belum end-to-end.
- Transaction detail/editor dapat dikembangkan lebih lanjut.

### AI
- Real AI provider belum menjadi implementation baseline.
- Financial chat Q&A belum end-to-end.
- Low-confidence AI review belum menjadi flow lengkap.

### Receipt/OCR
- Camera UI belum selesai.
- File attachment UI belum selesai.
- Receipt line-item parser belum lengkap.
- Receipt review/edit flow belum lengkap.

### Voice
- Voice UI belum terintegrasi penuh.
- Permission/device acceptance belum lengkap.
- Voice-to-multi-transaction end-to-end acceptance belum lengkap.

### Reports
- Pie chart expense/category belum lengkap.
- Transaction count visualization belum lengkap.
- Insight chart belum lengkap.
- Drill-down transaction belum lengkap.

### Backup
- Google OAuth/account connection UI belum lengkap.
- Automatic backup/restore belum lengkap.
- Manual backup/restore UI belum lengkap.
- Sync/conflict UX belum lengkap.

### Release
- Production signing/distribution masih perlu hardening.
- Self-install APK sengaja belum menjadi baseline.
- Rollback/recovery drill belum lengkap.

---

# 19. PRIORITAS PENGERJAAN

Jangan menentukan next task hanya berdasarkan nomor phase.

Gunakan urutan:

1. Bug yang memblokir build/CI.
2. Bug yang merusak data.
3. Bug yang merusak behavior existing.
4. Requirement PRD yang paling dekat dengan flow existing.
5. Integrasi end-to-end.
6. UX improvement.
7. Refactor/optimization.

Jika ada bug pada feature existing, **fix bug tersebut sebelum menambahkan fitur baru**.

---

# 20. CURRENT NEXT STEP

Baseline saat handoff:

**Phase 11.1.2 — analyzer fix**

Langkah pertama setelah melanjutkan:

1. Push/commit perubahan jika belum dilakukan.
2. Jalankan GitHub Actions.
3. Verifikasi:
   - `flutter analyze`
   - `flutter test`
   - `flutter build apk --release`
4. Jika gagal, perbaiki hanya error yang benar-benar dilaporkan.
5. Jangan melakukan perubahan tambahan yang tidak diperlukan.
6. Setelah test failure pada `transaction_entry_flow_test.dart` diperbaiki, verifikasi ulang seluruh CI sebelum melanjutkan fitur berikutnya.
6. Setelah CI stabil, lanjut ke backlog Phase 11 berdasarkan `docs/ROADMAP_AUDIT.md`.

Prioritas integrasi berikutnya dapat mencakup:

1. voice transaction UI;
2. camera/file receipt input;
3. receipt multi-transaction parser/review;
4. reports visualization/drill-down;
5. backup/restore UI;
6. financial chat Q&A;
7. end-to-end device acceptance.

Urutan aktual dapat berubah berdasarkan blocker dan requirement terbaru user.

---

# 21. FORMAT WAJIB SETIAP HANDOFF

Pada akhir setiap pekerjaan, `Ai start here.md` harus berisi kondisi terbaru:

## Current phase
...

## Last completed work
...

## Current implementation
...

## Verification
...

## Changed files
...

## Data/schema impact
...

## Architecture impact
...

## Known issues
...

## Known product gaps
...

## Exact next task
...

## Important instruction for next AI
...

---

# 22. LARANGAN

AI yang melanjutkan project ini **TIDAK BOLEH**:

- menghapus database untuk mengatasi error;
- force push;
- mengganti arsitektur tanpa alasan;
- menghapus test agar CI hijau;
- mengubah expected behavior existing tanpa persetujuan requirement;
- mengarang hasil test;
- mengklaim CI berhasil jika belum diverifikasi;
- menyatakan fitur product-complete hanya karena unit test lulus;
- membuat perubahan pada banyak file yang tidak diperlukan;
- mengubah dokumentasi menjadi lebih "bagus" tetapi tidak sesuai source code;
- menambahkan dependency besar tanpa alasan;
- mengubah schema tanpa migration;
- membuat AI menjadi source of truth.

---

# 23. PRINSIP UTAMA PROJECT

> **Pertahankan yang sudah berjalan. Ubah seminimal mungkin. Test setiap perubahan. Dokumentasikan setiap perubahan. Jangan kehilangan data. Jangan mengandalkan chat history.**

Repository harus selalu dapat diberikan kepada AI lain dan AI tersebut dapat melanjutkan pekerjaan hanya dengan membaca repository ini.

---

# 24. CHECKLIST SEBELUM MENYATAKAN PEKERJAAN SELESAI

- [ ] Requirement jelas.
- [ ] Source code terkait sudah diperiksa.
- [ ] Existing behavior tidak rusak.
- [ ] Perubahan dibuat seminimal mungkin.
- [ ] Test ditambah/diperbarui jika behavior berubah.
- [ ] `flutter analyze` diverifikasi jika tersedia.
- [ ] `flutter test` diverifikasi jika tersedia.
- [ ] Android release build diverifikasi jika tersedia.
- [ ] `Ai start here.md` diperbarui.
- [ ] `docs/IMPLEMENTATION_STATUS.md` diperbarui.
- [ ] `CHANGELOG.md` diperbarui.
- [ ] Dokumen lain yang terdampak diperbarui.
- [ ] Data/schema impact dicatat.
- [ ] Architecture impact dicatat.
- [ ] Known issues dicatat.
- [ ] Exact next task dicatat.
- [ ] Tidak ada force push.
- [ ] Tidak ada perubahan tidak perlu pada kode existing.

---

## FINAL HANDOFF RULE

**Jangan pernah mulai coding hanya karena user mengatakan "lanjut".**

Pertama:

`Baca → cek status → cek source → cek test → tentukan task → ubah minimum → test → update docs → CI → handoff`

Dengan aturan ini, project FinChat dapat dilanjutkan secara bertahap oleh AI lain tanpa kehilangan konteks, tanpa mengandalkan percakapan lama, dan dengan perlindungan terhadap kode yang sudah berjalan.
