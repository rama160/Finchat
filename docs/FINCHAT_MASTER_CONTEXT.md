## Verified GitHub CI — 0.3.2+13 (5 Oktober 2026)

- Tested code commit `02ea7a394e0af7afaedc85db5f44bf1ccef4aec3`, branch `codex/finchat-input-navigation-audit`.
- Run https://github.com/rama160/Finchat/actions/runs/37301937885 — success. Flutter stable 3.47.6: dependency resolution passed; analyze No issues found; **100 tests passed**; signed release APK **92.2 MB** built.
- APK: https://github.com/rama160/Finchat/actions/runs/37301937885/artifacts/11341239451 . Signing keystore and Google server client ID retained; no secrets changed.
- Regressions: Mahkota separate/noisy/column OCR and plain prices; exact keyword nota with zero AI calls; persistent typed categories and learning; inline save status; delete cancellation/confirmation; two-day comparison across year boundary; existing speech/token/Drive/storage/navigation tests.
- Gateway recovery snapshot: https://github.com/rama160/Finchat/actions/runs/37302216708 — npm ci, typecheck, lint, **17 tests** and Wrangler dry-run passed. Full corrected backend plus exact tested lockfile is included in the ZIP's separate AI-Gateway folder.
- GitHub write to rama160/AI-Gateway was rejected HTTP403 Resource not accessible by integration. No Gateway repo update or Cloudflare deployment occurred; live HTTP503 is not claimed resolved. Its main remains b7769af739b1550667c5a75e524d3d62e8f8a324.
- Finchat main remains 91252bddf4a4eadaa99dafe095f72c2e04a4bab1. Original three workflows, SQLite schema/lifecycle, money parser and transaction repository are byte-identical. Temporary backend snapshot validation is isolated in `codex/gateway-recovery-validation`; source ZIP retains the original workflow files.
- First run stopped on a redundant assertion warning, corrected. Second run exposed duplicate IDs caused by the test's frozen clock; its second input now advances the clock. Final suite and signed build passed. No product transaction-ID contract change.
- **Device/live gate open:** actual camera/attach OCR quality, Google/Gemini/Drive and report chart on Android must be retested. The fixture yields three products/Rp69.059; it is not a claim of real-device OCR success.
- This section supersedes older “verification pending” entries below. Final docs-only follow-up does not alter tested application code.

## Current device follow-up requirements — 0.3.2+13

- Scan struk kamera/lampiran tetap lokal: nama barang dan harga pada baris/kolom berbeda digabung berdasarkan posisi OCR, lalu item harus melalui review sebelum disimpan. Contoh Mahkota Mart berisi tiga item dengan total Rp69.059; total/tunai/kembali tidak menjadi transaksi.
- Pemberitahuan simpan berada dalam layout di atas composer, termasuk saat keyboard terbuka.
- Swipe hapus selalu meminta konfirmasi; Batal tidak menghapus. Edit kategori menerima teks bebas atau pilihan kategori, menyimpan kategori baru, dan mempelajari koreksi per pengguna.
- Filter satu hari menampilkan grafik dua bar: hari sebelumnya dan tanggal yang dipilih. Total/pie/PDF tetap hanya periode terpilih; rentang/bulan menggunakan grafik harian sesuai rentangnya.
- Pertanyaan “berapa total pengeluaran dengan kata acara, buat dalam bentuk nota” dijawab lokal dengan hanya deskripsi yang cocok; jawaban dan pertanyaan tetap terpisah.
- Perbaikan Gateway disediakan terpisah: HTTP503 live belum dinyatakan selesai sebelum source Gateway diterapkan dan permintaan autentikasi/provider nyata berhasil. Tidak mengubah schema, lifecycle database, kontrak penyimpanan, OAuth IDs, rahasia atau tiga workflow asli.

## Verified GitHub CI — 0.3.2+12 (5 Oktober 2026)

- Tested code commit: `93ccf38c8a7d5e8be9e386d86321dd8f9bbaee8f`, branch `codex/finchat-input-navigation-audit`.
- Run https://github.com/rama160/Finchat/actions/runs/37293049436 — completed / success.
- Flutter stable 3.47.6: dependency resolution passed; `flutter analyze` No issues found; **94 tests passed**; release APK **92.0 MB** built successfully.
- APK artifact: https://github.com/rama160/Finchat/actions/runs/37293049436/artifacts/11337048743 (`finchat-audit-release-apk`). Permanent release keystore and build Google server client ID retained; no secrets changed.
- Regression coverage includes final-vs-partial speech callbacks, word/numeric amounts, local multi-item capture with zero AI calls, scoped nota and local saving tips, active token reuse/expiry/concurrent restoration/logout, daily view rollover preserving SQLite, daily expense zero buckets/total reconciliation, user error messages and existing Back navigation.
- First iteration had 86 passing / 1 failing word-number regression (hundred arithmetic), corrected. Second iteration passed 92 tests and signed build; final iteration adds daily-reset/error-message regressions and passes 94 tests and signed build.
- Main remains `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`; three original workflows, schema, database lifecycle and transaction repository unchanged. Docs-only follow-up uses `[skip ci]` and does not change tested code.
- **Device gate remains open:** actual receipt OCR/camera/attach, microphone recognition quality, live Google/Gateway token refresh and Drive must be tried on Android. CI and keep-rule mitigation do not prove the obfuscated native OCR NPE is resolved on the user's device.

## Device follow-up — 0.3.2+12 (5 Oktober 2026)

- Capture teks/suara/struk kini menggunakan parser dan mapping lokal tanpa HTTP AI per item; mapping dibaca sekali per input. AI Q&A tetap tersedia sebagai fallback.
- Normalisasi nominal suara mendukung "nasi sepuluh ribu" serta "nasi 10 ribu".
- Provider AI menggunakan akun Google hasil authenticate yang diingat coordinator sebelum mencoba restorasi lightweight; JWT kedaluwarsa tidak digunakan dan cache dibersihkan saat sign-out.
- Pertanyaan nota dengan kata kunci menghitung dan merinci hanya deskripsi yang cocok; saran hemat dasar dapat dijawab lokal. Kendala yang belum didukung tidak diam-diam dijawab sebagai total keseluruhan.
- Input default hari ini; midnight/resume mengatur ulang tampilan harian dan Q&A tanpa menghapus data SQLite. Pertanyaan dan jawaban memakai bubble terpisah.
- Laporan mempertahankan total berdasarkan periode dan pie chart; bagian jumlah/detail transaksi di bawah chart diganti grafik pengeluaran harian. Hari tanpa pengeluaran bernilai nol; rentang/bulan mengikuti filter.
- Preprocessing gambar dipindahkan ke isolate. Error OCR tidak menampilkan stack trace di layar; cleanup recognizer tidak menimpa hasil. Keep rules native ML Kit/component registrar diperkuat untuk release.
- Tidak ada perubahan schema, database lifecycle, Drive backup, endpoint Gateway, secrets, atau tiga workflow asli. Perubahan login terbatas pada penyimpanan akun aktif, bukan alur pemilihan akun.
- Status: source patch teruji pada CI 37293049436; lihat hasil terbaru di atas. OCR native dan AI live perlu tes perangkat. Screenshot stack trace terobfuscate tidak cukup untuk memastikan akar NPE; keep rules adalah mitigasi release, bukan klaim hasil perangkat.

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
