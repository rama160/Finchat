# FinChat Phases

1. Product Definition & Repository Foundation — completed.
2. Flutter Foundation — completed; GitHub CI and Android build verified.
3. Transaction Engine — completed parser baseline.
3B. Local Database + Transaction Repository + Category Learning — current milestone.
4. AI Fallback — next after 3B passes CI.
5. Receipt/OCR & image preprocessing.
6. Voice input.
7. Reports and analytics.
8. PDF export.
9. Backup & Google Drive sync.
10. Update & release.
11. QA and integration testing.
12. Production hardening.

## Phase Control

Do not skip a blocking milestone. Every meaningful implementation change must update `IMPLEMENTATION_STATUS.md` and `CHANGELOG.md`. GitHub Actions is the canonical verification environment because the project is intentionally buildable without a local Flutter installation.
