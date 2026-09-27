# FinChat Phases

## Roadmap status

1. Product Definition & Repository Foundation — **completed baseline**.
2. Flutter Foundation — **CI/build completed**; secure session carry-over is now completed in Phase 10.
3. Transaction Engine — **parser baseline completed**.
3B. Local Database + Transaction Repository + Category Learning — **completed baseline**.
4. AI Fallback — **service/contract baseline completed**; real provider and financial Q&A remain backlog.
5. Receipt/OCR & image preprocessing — **service/adapter baseline completed**; camera/file UI and receipt line-item parser remain backlog.
6. Voice input — **service/adapter baseline completed**; UI/device acceptance remains backlog.
7. Reports and analytics — **report baseline completed**; required charts/interactive details remain backlog.
8. PDF export — **baseline completed**.
9. Backup & Google Drive sync — **backup provider baseline completed**; OAuth/automatic setup/UI/sync UX remain backlog.
10. Update & Release — **current**.
11. QA & End-to-End Integration — next.
12. Production Hardening — future.

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
