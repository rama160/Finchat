# FinChat Roadmap Audit — Baseline after Phase 9

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
