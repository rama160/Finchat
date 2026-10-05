## Device UX follow-up — 0.3.2+14 (5 Oktober 2026)

- Chat: transaksi dan Q&A tersusun berdasarkan waktu dalam satu timeline; pesan baru muncul paling bawah. Input dan status memiliki tinggi tetap, fokus/keyboard dipertahankan saat kirim, dan draft berikutnya tidak dikosongkan setelah proses sebelumnya selesai.
- Halaman Input tidak memiliki filter tanggal. Periode pertanyaan dibaca dari teks (hari/rentang/bulan/tahun); tanpa periode eksplisit, pertanyaan memakai seluruh riwayat. Daftar transaksi harian tetap reset tampilan saat berganti hari tanpa menghapus database.
- Header filter Laporan tetap sama; klik langsung membuka kalender Minggu–Sabtu dengan pilihan tanggal, rentang, bulan dan tahun. Satu bulan/tahun lengkap dikenali otomatis.
- Keterangan grafik berada di bawah grafik dan merangkum data, bukan fungsi. Total, pie, PDF dan insight tetap mengikuti periode; grafik satu hari tetap membandingkan dengan hari sebelumnya.
- Insight: arus kas, rata-rata belanja termasuk hari nol, puncak belanja, perubahan harian dan transaksi berulang/ukuran transaksi. Tidak menyimpulkan kondisi pendapatan keseluruhan saat pemasukan belum tercatat.
- Suara: sesi dictation, nominal kata/angka dan harga tanpa pemisah diproses lokal sebagai multi transaksi. Batas durasi/pause tetap dapat dibatasi Android; kualitas mic harus diuji di HP.
- Struk: satu batch category learning, tanpa parse ulang tiap produk, recognizer dipakai ulang selama layar hidup; resize kamera mengikuti batas OCR dan file sementara tidak memakai fsync. Review dan koreksi kategori tetap wajib. Tidak ada klaim pengurangan latency HP sebelum pengukuran perangkat.
- Schema, lifecycle database, money parser, transaction repository, OAuth/secrets, endpoint Gateway dan workflow asli dipertahankan.
- Status verifikasi patch ini: menunggu CI analyze/tests/signed APK. Tes regresi mencakup keyboard/fokus/posisi input, draft berikutnya, urutan chat, kalender, scope pertanyaan, insight, multi suara dan batch struk.
- Gateway terpisah telah diperbarui ke 0.1.1 dan live provider berhasil HTTP200/622 ms, endpoint probe dihapus. Bukti https://github.com/rama160/AI-Gateway/actions/runs/37316536289 . Catatan lama “belum deploy/HTTP403” di bawah adalah riwayat dan sudah digantikan hasil Gateway terbaru.

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

## Device receipt follow-up — 0.3.2+13 (5 Oktober 2026)

- Receipt parser joins product names with quantity/price rows, restores OCR column reading order from image coordinates, and excludes payment/header/footer rows. Mahkota Mart fixture: 3 items, Rp69.059; no payment or change recorded.
- Save success appears inline above the composer. Swipe delete requires explicit Hapus confirmation; Batal preserves data.
- Category edit accepts typed names and existing choices, persists custom categories without schema migration, and reuses the existing per-user correction learning.
- Single-day chart compares the previous day and selected day. Summary, pie and PDF retain the selected period only; date ranges/months retain daily buckets.
- Exact question “berapa total pengeluaran dengan kata acara, buat dalam bentuk nota” is answered locally from matching descriptions; it no longer requires Gateway.
- AI 503 remains an upstream operational issue until a corrected Gateway is deployed and tested against the real provider. Android OCR quality/camera/attach still requires device validation.
- Verification pending GitHub analyze/tests/signed APK. Original workflows, schema, database lifecycle, money parser and transaction repository retained.

# FinChat Phases

## Current patch — 0.3.2+11 (2026-10-05)

Authoritative current audit: `AUDIT_0.3.2+11.md`. Fixes RouterDelegate navigatorKey/system Back, CI FFI factory setup, integrated local/AI questions, money-in-question routing, guarded camera/file pickers, voice cancel callbacks, Google Drive snapshot acknowledgements, bottom navigation reports and shared smart period filter. Transaction cards use gestures only; white rounded composer includes emoji/attachment/camera/mic/send.

SQLite schema and existing workflows unchanged. Source is matched to main commit `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Flutter SDK unavailable locally; CI and real Android device acceptance are required. Baseline CI had 72 passed / 1 failed (global FFI factory test setup); do not describe the baseline result as verification of this patch.


## Roadmap status

1. Product Definition & Repository Foundation — **completed baseline**.
2. Flutter Foundation — **CI/build completed**; secure session carry-over is now completed in Phase 10.
3. Transaction Engine — **parser baseline completed**.
3B. Local Database + Transaction Repository + Category Learning — **completed baseline**.
4. AI Fallback — **service/contract baseline completed**; real provider and financial Q&A remain backlog.
5. Receipt/OCR & image preprocessing — **technical baseline completed**; Phase 11.2 vertical integration is implemented and test-verified.
6. Voice input — **technical baseline completed**; Phase 11.3 UI integration is implemented, with device acceptance deferred to final Phase 11 QA.
7. Reports and analytics — **report baseline completed**; Phase 11.4 integration now implements charts/interactive details.
8. PDF export — **baseline completed**.
9. Backup & Google Drive sync — **provider baseline completed**; Phase 11.5 implements local backup UI, Google OAuth wiring and Drive sync UX. Automatic execution remains an explicit verification/hardening item.
10. Update & Release — **completed**.
11. QA & End-to-End Integration — **CI/release verified; device acceptance pending**.
12. Production Hardening — **implemented 12.1–12.8; CI/device acceptance pending**.

## Phase 10 — Update & Release

### Completed in this phase
- Secure persistent session storage.
- Settings entry point.
- App version bump to `0.2.0+2`.
- GitHub Release update checker using the public latest-release API.
- Semantic version comparison for update availability.
- Release page launch from Settings.
- Release workflow default tag aligned with app version.
- Comprehensive roadmap audit and handoff-document reconciliation.

### Deferred intentionally
- Silent/self-install APK update.
- Production signing/key management.
- Play Store publishing.
- Rollback automation.

## Phase 11 — QA & End-to-End Integration

Close the product-level gaps identified by `docs/ROADMAP_AUDIT.md`:
- transaction entry/edit UI;
- camera/file attachment UI;
- receipt line-item parser and review;
- voice transaction UI;
- report charts and drill-down details;
- backup/restore settings UI;
- Google OAuth/account setup and automatic backup/restore;
- financial chat Q&A using application-computed data;
- end-to-end device tests and permission flows.

## Phase 12 — Production Hardening

- signed release and distribution;
- database migration drills;
- backup/restore disaster recovery drills;
- security review;
- crash/error handling;
- performance and storage review;
- release/rollback checklist;
- final acceptance against PRD.

## Phase control

A phase may contain carry-over remediation from an earlier phase when the missing work blocks the current release goal. Every such remediation must be explicitly documented instead of silently rewriting the historical phase status.

GitHub Actions remains the canonical CI environment because the project is intentionally buildable without a local Flutter installation.


### Phase 11.2 Receipt/OCR — IMPLEMENTED; DEVICE VERIFICATION PENDING

The vertical slice now connects camera/gallery input to the existing preprocessing and ML Kit OCR services, parses multiple receipt line items, presents a review/edit screen, learns category corrections, and persists reviewed transactions to SQLite. Device permission/error handling and release/device verification remain acceptance work.


## Phase 11.3 — Voice transaction integration — IMPLEMENTED; DEVICE VERIFICATION PENDING

Implemented vertical integration:
- microphone button in the transaction composer;
- Indonesian `id_ID` speech recognition;
- listening/stopping/error state feedback;
- transcript routed through the same `TransactionIntelligenceService` as text input;
- multi-transaction voice input supported by the existing parser;
- voice transactions persist with `InputSource.voice`;
- voice service now exposes change notifications for UI state;
- service test verifies UI notifications and Indonesian locale propagation.

Device microphone permission and physical-device acceptance are intentionally deferred until the final Phase 11 end-to-end test cycle.


## Phase 11.4 — Reports/PDF
Implemented: arbitrary day selection, date-range selection, month/year selection, summary metrics, expense-category aggregation, transaction-count visualization, insight card, drill-down to matching transactions, empty/loading/error states, and enhanced PDF category summary.

## Phase 11.5 — Backup/Google Drive
Implemented: local JSON export/import, restore confirmation, Google Sign-In authorization, Drive `appDataFolder` provider wiring, status/error UX, and persisted automatic-backup preference. Actual automatic execution is not claimed until device/network verification and a safe trigger policy are accepted.

## Phase 11.6 — AI
Implemented: concrete OpenAI-compatible provider behind the existing `AiCategoryProvider` contract, secure configuration, local-first category classification, malformed/offline fallback, and financial Q&A using application-computed report data. AI does not write SQLite.

## Phase 11.7 — End-to-End QA
QA tooling and matrix are implemented. The project owner has verified the cumulative package through analyze, tests, and release APK. Real-device execution remains pending and is intentionally scheduled after Phase 12 hardening.


## Phase 12 gate
Phase 12 engineering may proceed after the Phase 11 code path reaches Analyze, Tests, and Release-build verification. Device verification remains the final product-acceptance gate and is not claimed by this package.

### Phase 11 CI correction
After the 11.4–11.7 cumulative merge, analyzer cleanup was required for integration imports, an unused Drive import, report-screen syntax, and tests aligned to the current report/AI contracts. This is a CI stabilization step; feature scope is unchanged.


## PHASE 12 — Production Hardening
12.1 Stability & Crash Hardening
12.2 Data Integrity
12.3 AI Reliability & Safety
12.4 Performance
12.5 Security
12.6 UX Resilience
12.7 Release Hardening
12.8 Final Product Acceptance

Delivered as one cumulative package while retaining separate sub-phase scope.

## Phase 12 account and monetization foundation
Added Google Sign-In session integration and the disabled foundation for four subscription tiers and multiple payment methods. Monetization remains OFF during pilot testing. Google OAuth and backend verification are device/configuration gates, not claimed by source-level CI.
