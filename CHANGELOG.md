# Changelog

## Unreleased

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
