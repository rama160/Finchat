> Current source status: **0.3.4+19**, 9 October 2026 UTC. See [SPENVA_CANONICAL_SOURCE.md](SPENVA_CANONICAL_SOURCE.md) and the current detailed audit. Older version/build statements below are historical evidence and do not verify this patch.

# Phase 12 — Production Hardening Matrix

## Purpose
Phase 12 hardens the completed Phase 11 product without replacing its architecture.

## 12.1 Stability & Crash Hardening
- Transaction load/edit/delete failures are surfaced without crashing the screen.
- Repeated transaction submission remains guarded by the existing processing state.
- Transaction input is validated before orchestration.

## 12.2 Data Integrity
- Transaction persistence validates identity, amount, description, category and confidence.
- Multi-transaction saves use one SQLite transaction and reject duplicate IDs in the batch.
- Backup structure is validated before destructive restore; restore remains transactional.
- No SQLite schema migration is introduced.

## 12.3 AI Reliability & Safety
- AI remains opt-in and local-first.
- Enabled AI requires API key, model and HTTPS endpoint.
- Requests have a 20-second timeout and responses have a size guard.
- Malformed/network AI results fall back safely.

## 12.4 Performance
- Existing database indexes remain in use.
- OCR image width remains bounded.
- Batch transaction persistence reduces per-row database commits.
- AI network calls are bounded.

## 12.5 Security
- API credentials remain in secure storage.
- Enabled AI endpoint must use HTTPS.
- Android application backup remains disabled because FinChat owns its backup format.
- Google Drive remains scoped to `drive.appdata`.

## 12.6 UX Resilience
- Invalid login input gets a visible validation message.
- PDF export is guarded against repeated taps and reports failures.
- Backup import errors are shown instead of escaping the screen.

## 12.7 Release Hardening
- Version advanced to `0.3.0+3`.
- Release workflow checks tag/version consistency and publishes an APK SHA-256 checksum.
- Production signing credentials are not embedded; repository-owner keystore configuration remains required for signed production distribution.

## 12.8 Final Product Acceptance
- GitHub Actions analyze succeeds.
- Full Flutter tests succeed.
- Release APK build succeeds.
- APK installs on the target Android device.
- One complete Phase 11 + Phase 12 device QA cycle passes.
