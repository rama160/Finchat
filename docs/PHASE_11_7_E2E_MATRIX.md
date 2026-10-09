> Current source status: **0.3.4+19**, 9 October 2026 UTC. See [SPENVA_CANONICAL_SOURCE.md](SPENVA_CANONICAL_SOURCE.md) and the current detailed audit. Older version/build statements below are historical evidence and do not verify this patch.

# Phase 11.7 — End-to-End QA Matrix

## Status rule
Phase 11.7 is the final verification phase for Phase 11. It is **not** considered device-verified until the checklist below has been executed on a real Android device with a release APK.

## A. Fresh install / session
- [ ] Install release APK on clean device.
- [ ] Launch from cold start.
- [ ] Login with a valid test account/session.
- [ ] Logout and verify login screen returns.
- [ ] Relaunch and verify session behavior.

## B. Text transaction
- [ ] Single expense is parsed and saved.
- [ ] Single income is parsed and saved.
- [ ] Multi-transaction sentence creates all expected rows.
- [ ] Edit changes amount/type/category/date.
- [ ] Category correction is learned.
- [ ] Delete removes the transaction from active list.
- [ ] Double tap/send does not duplicate the same action unexpectedly.

## C. OCR / receipt
- [ ] Camera permission allow.
- [ ] Camera capture reaches OCR review.
- [ ] Camera permission deny shows recoverable error.
- [ ] Gallery/file input reaches OCR review.
- [ ] Multiple receipt lines become separate transactions.
- [ ] Quantity line uses the line total, not unit price.
- [ ] Review/edit works before persistence.
- [ ] OCR failure/retry works.

## D. Voice
- [ ] Microphone permission allow.
- [ ] Listening state is visible.
- [ ] Indonesian speech produces transcript.
- [ ] Transcript enters the same transaction intelligence pipeline.
- [ ] Multiple transactions are split correctly.
- [ ] Stop/cancel/retry works.
- [ ] Permission denial is recoverable.

## E. Reports/PDF
- [ ] Day report can select an arbitrary date.
- [ ] Range report can select start/end dates.
- [ ] Month report can select month/year.
- [ ] Totals and transaction counts match the transaction list.
- [ ] Category chart renders.
- [ ] Transaction count chart renders.
- [ ] Insight is consistent with local totals.
- [ ] Drill-down opens matching transactions.
- [ ] Empty period is handled without crash.
- [ ] PDF opens/shares successfully.
- [ ] PDF values match the selected period.

## F. Backup / Google Drive
- [ ] Local export creates a JSON backup.
- [ ] Local import requires confirmation.
- [ ] Restore replaces local data as documented.
- [ ] Google account authorization succeeds.
- [ ] Drive backup uploads to appDataFolder.
- [ ] Drive restore downloads and restores the latest backup.
- [ ] Network/auth failure shows a recoverable error.
- [ ] No API key/OAuth token is visible in UI logs or source-controlled files.

## G. AI
- [ ] AI disabled: app remains usable with local parser/learning.
- [ ] AI enabled with valid configuration: low-confidence category fallback can call provider.
- [ ] Invalid/malformed AI response falls back safely.
- [ ] Network unavailable falls back safely.
- [ ] Financial Q&A uses the selected date range.
- [ ] Q&A numbers correspond to application-computed report totals.
- [ ] API key is not written to SQLite or source code.

## H. Release regression
- [ ] `flutter analyze` clean.
- [ ] `flutter test` clean.
- [ ] `flutter test integration_test/phase_11_end_to_end_test.dart` executed in supported integration environment.
- [ ] `flutter build apk --release` succeeds.
- [ ] Release APK installs and launches.
- [ ] Back navigation works from Report, Backup, AI Q&A and Settings.
- [ ] No fatal exception/crash in the tested flows.

## Evidence to record
For each checked item record date, device model, Android version, app version/build number, result, and a short note/screenshot reference where useful.

## Completion labels
- Implemented = code exists.
- Analyze verified = analyzer clean.
- Tests verified = automated tests pass.
- Release build verified = release APK builds.
- Device verified = real Android checklist executed.
- Product accepted = user confirms the Phase 11 behavior is acceptable.
