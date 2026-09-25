# Phases

1. Product Definition & Repository Foundation — completed.
2. Flutter Foundation — completed; GitHub Actions analyze/test/build passed.
3. Transaction Engine — **current**.
4. AI Fallback & Financial Q&A.
5. Receipt OCR, preprocessing & multi-transaction extraction.
6. Voice input.
7. Reports & insights.
8. PDF/export.
9. Backup & Google Drive sync.
10. Update & release.
11. QA.
12. Production hardening.

## Phase 3 control
The local transaction parser is the first processing layer. It must recognize common Indonesian money notation, including shorthand such as `rb`, `ribu`, `k`, `jt`, `juta`, `m`, and grouped Rupiah numbers. AI must not bypass parser validation or write directly to the database.
