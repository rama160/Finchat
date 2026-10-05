## Device receipt follow-up — 0.3.2+13 (5 Oktober 2026)

- Receipt parser joins product names with quantity/price rows, restores OCR column reading order from image coordinates, and excludes payment/header/footer rows. Mahkota Mart fixture: 3 items, Rp69.059; no payment or change recorded.
- Save success appears inline above the composer. Swipe delete requires explicit Hapus confirmation; Batal preserves data.
- Category edit accepts typed names and existing choices, persists custom categories without schema migration, and reuses the existing per-user correction learning.
- Single-day chart compares the previous day and selected day. Summary, pie and PDF retain the selected period only; date ranges/months retain daily buckets.
- Exact question “berapa total pengeluaran dengan kata acara, buat dalam bentuk nota” is answered locally from matching descriptions; it no longer requires Gateway.
- AI 503 remains an upstream operational issue until a corrected Gateway is deployed and tested against the real provider. Android OCR quality/camera/attach still requires device validation.
- Verification pending GitHub analyze/tests/signed APK. Original workflows, schema, database lifecycle, money parser and transaction repository retained.

# FinChat Roadmap Audit — Baseline after Phase 9

## Current patch — 0.3.2+11 (2026-10-05)

Authoritative current audit: `AUDIT_0.3.2+11.md`. Fixes RouterDelegate navigatorKey/system Back, CI FFI factory setup, integrated local/AI questions, money-in-question routing, guarded camera/file pickers, voice cancel callbacks, Google Drive snapshot acknowledgements, bottom navigation reports and shared smart period filter. Transaction cards use gestures only; white rounded composer includes emoji/attachment/camera/mic/send.

SQLite schema and existing workflows unchanged. Source is matched to main commit `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Flutter SDK unavailable locally; CI and real Android device acceptance are required. Baseline CI had 72 passed / 1 failed (global FFI factory test setup); do not describe the baseline result as verification of this patch.


Tanggal audit: 27 September 2026
Sumber: repository ZIP yang dikirim user, git history sampai commit `25064f5 phase 9 v2`, dan requirement FinChat yang tercatat di project documentation.

## Kesimpulan

Phase 1–9 memiliki fondasi teknis yang nyata dan test coverage bertambah secara bertahap. Namun status "phase selesai" tidak sama dengan "seluruh PRD end-to-end selesai". Beberapa phase saat ini baru menyediakan contract/service/adapter dan test, sementara UI integration, device integration, OAuth, dan beberapa acceptance criteria produk belum lengkap.

Phase 10 karena itu dibagi menjadi dua jenis pekerjaan:
1. **Release/update foundation** — update checker berbasis GitHub Releases, secure persistent session, Settings entry point, versioning, dan release documentation.
2. **Carry-over backlog** — gap PRD yang harus ditutup pada Phase 11–12 sebelum production readiness.

## Phase matrix

| Phase | Status teknis | Sudah ada | Gap penting |
|---|---|---|---|
| 1 | Complete baseline | PRD, architecture, phase docs, CI/uploader | Wireframe/UX acceptance belum menjadi UI final |
| 2 | Complete CI foundation; product carry-over | Flutter foundation, router, CI, Android build | Session masih in-memory pada baseline audit; transaction UI belum lengkap |
| 3 | Complete parser baseline | Rupiah shorthand, multi-expression parser | Parser belum menjadi full transaction-entry UI |
| 3B | Complete persistence baseline | SQLite, repository, category mapping/history | Repository belum sepenuhnya di-wire ke UI/application composition |
| 4 | Complete service baseline | AI fallback contract + transaction intelligence | Belum ada provider AI nyata; chat financial Q&A belum end-to-end |
| 5 | Complete OCR baseline | preprocessing + ML Kit adapter + service | Camera/file picker UI dan receipt parser multi-line belum lengkap |
| 6 | Complete voice service baseline | speech contract + adapter + service | Voice UI/device permission flow belum end-to-end |
| 7 | Complete report baseline | daily/range/month report, grouping, report screen | Pie chart/category counts, tap-through transaction details, insight chart belum lengkap |
| 8 | Complete PDF baseline | A4 PDF + share/export | Production UX and file lifecycle need device verification |
| 9 | Complete backup baseline | JSON snapshot, restore, Google Drive provider | OAuth/account setup, automatic trigger, settings UI, offline backup/restore UI, sync/conflict workflow belum lengkap |
| 10 | **Current** | secure session, update checker, settings entry, release versioning | APK self-install/update automation remains deferred; release signing/distribution needs hardening |
| 11 | Next | — | End-to-end integration, device QA, permissions, failure paths, UI acceptance |
| 12 | Future | — | production hardening, security, observability, release signing, migration drills |

## Requirement gaps from original PRD

### Authentication/session
- [x] Login screen baseline.
- [x] Logout.
- [x] Persistent session implementation added in Phase 10 using secure storage.
- [ ] Real authentication/identity provider, if required later, is not implemented.

### Transaction entry
- [x] Local parser.
- [x] Indonesian amount shorthand: `25 rb`, `25 ribu`, `25k`, etc.
- [x] Multi-transaction parsing baseline.
- [x] Local database/repository.
- [x] Category learning baseline.
- [ ] Full transaction entry/edit UI.
- [ ] Camera and attachment input UI.
- [ ] Transaction detail editor wired to repository.

### AI
- [x] AI fallback contract.
- [x] AI category fallback abstraction.
- [x] Transaction intelligence orchestration.
- [ ] Real AI provider configuration.
- [ ] Financial chat/question answering over application-computed data.
- [ ] Review UI for low-confidence AI output.

### Receipt/OCR
- [x] Image preprocessing before OCR.
- [x] ML Kit adapter.
- [ ] Camera UI.
- [ ] File attachment UI.
- [ ] Receipt line-item parser producing multiple transactions.
- [ ] Receipt review/edit screen.

### Voice
- [x] Provider abstraction.
- [x] `speech_to_text` adapter.
- [ ] Microphone UI integrated with transaction input.
- [ ] Device permission UX and Indonesian locale selection in product UI.
- [ ] Voice-to-multi-transaction end-to-end acceptance test.

### Reports
- [x] Income/expense totals.
- [x] Daily/range/month periods.
- [x] Grouped transaction details.
- [x] PDF export.
- [ ] Expense pie chart by category.
- [ ] Transaction count per category visualization.
- [ ] Additional chart/insight.
- [ ] Tap income/expense/category into transaction detail list.

### Backup/sync
- [x] Local JSON snapshot.
- [x] Transactional restore.
- [x] Google Drive provider abstraction.
- [ ] Google OAuth/account connection UI.
- [ ] Automatic backup after account setup.
- [ ] Automatic restore flow after account setup.
- [ ] Manual offline backup/restore UI.
- [ ] Sync status/conflict resolution UX.

### Update/release
- [x] Versioned app package.
- [x] GitHub Release workflow.
- [x] Update checker against public GitHub Releases.
- [x] Settings entry point.
- [ ] Signed production APK/Play distribution.
- [ ] In-app installation flow where distribution channel permits it.
- [ ] Rollback/update failure recovery drill.

## Documentation gaps found in the supplied ZIP

The source code had reached Phase 9, but several handoff documents still described Phase 2 as the current phase. `README.md` and `Ai start here.md` also listed old Phase 2 next steps. The changelog contained Phase 6–9 entries but not a complete historical record of Phases 1–5.

Phase 10 updates these documents so another AI can use the repository without relying on the chat history.

## Rule for future phases

Every phase must update all applicable handoff artifacts:
- `Ai start here.md`
- `README.md`
- `docs/FINCHAT_MASTER_CONTEXT.md`
- `docs/PRD.md` when acceptance criteria change
- `docs/ARCHITECTURE.md` when architecture changes
- `docs/PHASES.md`
- `docs/AI_CONTRACT.md` when AI behavior changes
- `docs/IMPLEMENTATION_STATUS.md`
- `CHANGELOG.md`
- tests for changed behavior

A phase is not considered product-complete merely because `flutter analyze` and unit tests pass. End-to-end acceptance must also be marked separately.


## Phase 11.1 progress

The first end-to-end vertical slice is now connected: text composer -> parser/intelligence -> editable review -> SQLite transaction repository. Multiple transactions are supported in one input, and user category corrections are persisted as local mappings/history. Voice, receipt, reports visualization/drill-down, backup UI and financial Q&A remain subsequent Phase 11 work.


## Phase 11.2 Receipt/OCR progress
- Existing OCR technical baseline reused; no duplicate OCR provider created.
- UI entry point: receipt attachment action in the chat composer.
- Sources: camera and gallery.
- Review gate: OCR results are not written directly to SQLite; they pass through review first.
- Persistence: only reviewed transactions are saved through the existing SQLite repository.
- Learning: category corrections are recorded after review.
- Remaining acceptance: full analyze/tests, release APK, real-device camera/gallery permissions, poor-image and malformed-receipt scenarios.


## Phase 11.3 Voice audit update

The voice vertical slice is now integrated into the existing chat transaction flow. The microphone action initializes the existing speech adapter, requests/uses Indonesian speech recognition, captures transcript state, and sends the transcript through `TransactionIntelligenceService` before SQLite persistence. The implementation records `InputSource.voice` and does not create a parallel persistence path.

Acceptance deliberately remains split: automated source/test verification is a CI responsibility, while microphone permission, actual speech recognition quality, interruption behavior, and device UX are deferred to the final Phase 11 device QA cycle.


### Phase 11.4 audit
- Scope: Reports/PDF integration.
- SQLite schema: unchanged.
- Existing report date/range/month selectors preserved.
- Added category/count summaries, insight, drill-down, empty/loading/error handling and PDF category summary.
- Device verification remains pending for Phase 11.7.


### Phase 11.5 audit
- Existing BackupService and GoogleDriveBackupProvider retained and wired into user-facing UI.
- Google authentication uses the current google_sign_in authorization model and an official bridge to googleapis.
- No SQLite schema change; automatic-backup preference uses existing app_settings.
- Device OAuth/Drive verification deferred to Phase 11.7.


### Phase 11.6 audit
- Existing AiCategoryProvider/AiCategoryFallback contracts retained.
- AI provider is concrete but opt-in and safe when unconfigured.
- Q&A uses ReportService-computed totals and transaction data; AI does not write to SQLite.
- Secure credentials are kept outside SQLite.


### Phase 11.7 audit
- QA covers all Phase 11.1–11.6 vertical slices, permissions, malformed/offline states, release build and Android device verification.
- No production schema change introduced by QA tooling.
- Phase 12 engineering is now prepared from the CI/release-verified Phase 11 baseline. Phase 11 device/product acceptance remains a separate final verification gate.

### Phase 11 CI stabilization note
The cumulative 11.4–11.7 package required analyzer corrections after merge. The corrections are limited to syntax/import cleanup and test alignment with already-existing production contracts. They do not change the Phase 11 feature scope or SQLite schema. The Phase 11 cumulative package has since been reported by the project owner as passing analyze, test, and release APK. Phase 12 now requires a fresh CI run after hardening changes.


## Phase 12 audit
Phase 12.1–12.8 is implemented from the CI/release-verified Phase 11 baseline. No SQLite schema migration. Production signing is not fabricated and still depends on repository-owner keystore secrets. Device verification remains the final acceptance gate.

### Multi-user / monetization audit
- Google Sign-In is integrated without changing the SQLite schema.
- Local `userId` remains normalized email for compatibility with existing user-scoped transaction data.
- Google provider user ID is stored in secure session storage for future backend identity linking.
- Four subscription tiers and payment methods are modeled but monetization is disabled.
- Production payment and subscription entitlement must be server-side; no payment credential is embedded in the Android client.

### Google OAuth build configuration audit
- No prior Phase 12 business logic was reverted or removed.
- CI configuration now passes the Google server client ID without committing it to source.
- Release default tag is aligned with `pubspec.yaml` version.

---

## Repository re-audit — 2026-09-29 / version 0.3.2+5

A full file-by-file audit of the cumulative repository was completed. The authoritative detailed matrix is now `docs/FULL_REPOSITORY_AUDIT.md`.

The re-audit found that technical code existed through Phase 12, but several original product requirements were still only partial in the uploaded ZIP. This package closes the static gaps that can be addressed without a physical Android device:

- explicit receipt image-file attachment in addition to camera/gallery;
- finance-question recognition from the main chat composer;
- local-first answers for common finance questions before AI fallback;
- true expense pie chart and transaction count per category;
- tapping income/expense summaries to inspect matching transactions;
- automatic Google Drive backup that actually executes after one-time authorization;
- one shared Android CI configurator for build and release workflows;
- one Windows GitHub sync script that stages additions, updates and deletions;
- stale phase-copy files consolidated and handoff/status documents reconciled.

This re-audit does **not** claim runtime acceptance. Fresh GitHub Actions and one real-device QA cycle remain required because the artifact workspace has no Flutter/Dart SDK and cannot validate microphone, camera, OAuth/Drive, OCR quality or platform sharing behavior.


## Runtime re-audit — 2026-10-05 / version 0.3.2+6

The device report exposed two runtime regressions after the Phase 12 audit: shared SQLite handles could be closed by screen lifecycle disposal, and the new Cloudflare Gateway provider was still blocked by the legacy local AI enable flag. Both are fixed without changing the established Google Sign-In, restore/migration, parser-first, OCR, voice, backup or release workflows. GitHub Actions and real-device verification remain mandatory.
