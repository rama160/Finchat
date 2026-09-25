# FinChat Master Context

## Identitas
FinChat adalah Android personal finance assistant berbasis Flutter, chat-first, offline-first.

## Non-negotiable
- Local database adalah source of truth.
- Parser lokal selalu dicoba sebelum AI fallback.
- AI tidak boleh menulis database secara langsung.
- Semua output AI/OCR harus divalidasi.
- Kategori harus konsisten berdasarkan koreksi user, mapping lokal, rule, konteks, lalu AI.
- Receipt dari kamera/attachment harus dipreprocess/kompres sebelum OCR.
- Satu input/struk dapat menghasilkan banyak transaksi.
- Session harus persistent; user tidak login ulang setiap membuka app kecuali logout/session invalid.
- Google Drive hanya backup/sync, bukan primary database.
- Update aplikasi harus menjaga data melalui migration.
- Perubahan penting wajib dicatat di changelog.
- Tidak boleh ada force push otomatis.

## Pipeline transaksi
Input → normalize → local parser → confidence → category resolution → validation → AI fallback jika diperlukan → validation → review jika diperlukan → repository → local DB.

## Prioritas kategori
1. Koreksi user
2. Mapping lokal yang dipelajari
3. Local rules
4. Context/history
5. AI
6. Lainnya

## Receipt pipeline
Camera/file → validate → orientation → resize/compression adaptif → enhancement opsional → OCR → receipt parser → multi-transaction parser → category resolution → review → save.

## Session
Splash → SessionManager → session valid → app; tidak ada session → login.

## Entity transaksi minimum
`id`, `userId`, `type`, `amount`, `description`, `categoryId`, `transactionDate`, `transactionTime`, `inputSource`, `processedBy`, `confidence`, `createdAt`, `updatedAt`, `deletedAt`, `syncStatus`.

## Development workflow
User dapat bekerja tanpa Flutter lokal. GitHub Actions adalah environment canonical untuk `flutter pub get`, analyze, test, dan Android build. Jika folder `android/` belum ada, workflow build akan membuatnya di runner dengan `flutter create --platforms=android`.

## Dokumentasi
`Ai start here.md` → master context → PRD → architecture → phases → AI contract → implementation status → changelog.
