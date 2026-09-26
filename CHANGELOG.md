# Changelog

## Unreleased

### Phase 9 — Backup & Google Drive Sync

- Added versioned JSON backup snapshots for all local SQLite tables.
- Added transactional local restore and provider-agnostic cloud backup flow.
- Added Google Drive `appDataFolder` provider for a private FinChat backup file.
- Added backup serialization, restore, and fake cloud provider tests.

### Phase 8 — PDF Export

- Added `pdf` and `printing` dependencies for PDF generation and platform sharing.
- Added A4 PDF report generation from Phase 7 report data.
- PDF includes summary totals, transaction count, and grouped transaction details with occurrence count.
- Added PDF export action to the report screen.
- Added automated PDF generation and filename tests.

### Phase 7 — Reports & Analytics

- Added report domain models for summaries and grouped transaction details.
- Added daily, custom date-range, and monthly report generation.
- Added grouping of repeated transaction details by normalized description, type, and category.
- Added transaction count and combined amount for each grouped detail.
- Added report screen with selectable day, date range, and month/year.
- Added report navigation from the main screen.
- Added report service tests covering grouping and date boundaries.

### Phase 6 — Voice Input

- Added provider-agnostic speech recognition contract.
- Added `speech_to_text` adapter using `SpeechListenOptions`.
- Added voice input application service and CI-safe tests.
