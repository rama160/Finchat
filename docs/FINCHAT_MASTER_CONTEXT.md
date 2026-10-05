# FinChat Master Context

## Current patch — 0.3.2+11 (2026-10-05)

Authoritative current audit: `AUDIT_0.3.2+11.md`. Fixes RouterDelegate navigatorKey/system Back, CI FFI factory setup, integrated local/AI questions, money-in-question routing, guarded camera/file pickers, voice cancel callbacks, Google Drive snapshot acknowledgements, bottom navigation reports and shared smart period filter. Transaction cards use gestures only; white rounded composer includes emoji/attachment/camera/mic/send.

SQLite schema and existing workflows unchanged. Source is matched to main commit `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Flutter SDK unavailable locally; CI and real Android device acceptance are required. Baseline CI had 72 passed / 1 failed (global FFI factory test setup); do not describe the baseline result as verification of this patch.


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

## Phase 3 parser requirement
Indonesian monetary input must support both formal and informal notation. At minimum the local parser recognizes `25 rb`, `25 ribu`, `25k`, `Rp25.000`, `Rp 25.000`, `1 juta`, `1,5 juta`, `1.5jt`, `2m`, and larger grouped numbers. Multiple monetary expressions in one text input must be eligible for multiple transaction extraction. The parser remains offline-first; AI is fallback only after local parsing and validation cannot resolve the input.

## Local Database and Category Learning

SQLite is the local source of truth. The database contains users, categories, transactions, category mappings, category history, and app settings. Transactions are accessed through repositories rather than directly from presentation code. Transaction deletion is soft-delete so future synchronization can preserve deletion state.

Category learning is local and user-specific. A correction such as `cabe -> Belanja Dapur` is stored as a normalized mapping with source, confidence, usage count, and timestamps. Each correction also creates a category-history record. Resolution priority favors user corrections/mappings before fallback rules or AI. AI must never silently override a confirmed user mapping.

## Current repository baseline after Phase 9

The repository has technical baselines through Phase 9. Product-level gaps are tracked in `docs/ROADMAP_AUDIT.md`; do not assume a passing unit-test phase means every original UI acceptance criterion is complete.

## Phase 10 update/release

- Session persistence is implemented with secure device storage.
- Update checking uses the public GitHub Releases latest-release endpoint for `rama160/Finchat`.
- The app can open the published release page when a newer semantic version is detected.
- Release workflow and application version are aligned at `0.2.0+2` for this milestone.
- Automatic/self-install APK update is not claimed complete.


## Phase 12 state
Phase 12.1–12.8 hardening is prepared cumulatively. No SQLite schema change. CI and Android device verification remain the final external gates.
