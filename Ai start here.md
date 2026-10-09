# AI START HERE — Spenva / FinChat

Current patch: **0.3.4+19**, 9 October 2026 UTC (10 October in Asia/Makassar).
Repository: `rama160/Finchat`. Canonical integration source: `spenva-source-of-truth`; baseline `da61888d8151ee5bff52cea2a4cff846da8d5aa1`. Do not start from old main or copy older PR branches over this source. The older handoffs and evidence are archived in `docs/history/AI_HANDOFF_HISTORY.md`.

Read in order:
1. `docs/SPENVA_CANONICAL_SOURCE.md`
2. `docs/FULL_REPOSITORY_AUDIT.md`
3. `docs/IMPLEMENTATION_STATUS.md`
4. `docs/PRD.md` and `docs/ARCHITECTURE.md`
5. `docs/AI_CONTRACT.md`
6. `docs/playstore/SUBSCRIPTION.md`, `LAUNCH.md`, `DATA_SAFETY.md`, `VALIDATION.md`
7. `CHANGELOG.md` and actual source/tests.

Non-negotiable rules:
- Preserve the existing Google login/session mapping, application ID `com.finchat.finchat`, database `finchat.db`, schema 1, signing identity and restore compatibility.
- SQLite is the source of truth. Text/voice/receipt capture resolves locally first; AI cannot write to SQLite. Preserve local category learning, receipt review, gesture editing/deletion, current logo/offline assets and input/report UX.
- Public plans are Free/Plus/Pro/Max, generated from `assets/config/subscription_plans.json`. Never add external checkout or enable subscriptions, personal AI or paid infrastructure automatically.
- Backup remains whole-database replacement with confirmation and legacy `local_user` mapping. Invalid snapshots must fail before deletion. Cloud acknowledgement only marks uploaded row versions. Deletion and cloud backup retain `DataOperationGate` serialization.
- Background Drive backup may not open a Google authentication UI or block transaction capture.
- Do not use a whitelist to delete unknown tracked files. Remove only proven obsolete instructions, generated caches and outputs; retain assets, licenses, tests and historical evidence.
- No automatic force push. UPDATE_GITHUB targets the canonical integration source.

Verification:
The +18 canonical branch last CI failed one stale external-payment expectation (133 passed, 1 failed, 2 skipped); this patch updates that contract to Play Billing only. Backend 46 tests, Android template 3 tests and publication validator 5 tests pass locally. Standalone Dart syntax formatting is available. Local Flutter execution was blocked by automatic review after attempted metadata-service network access; do not claim local Flutter analyze/test/build. GitHub CI for `2f8d47e642c835197ffd9786f0013d12a7f79d5d` passed: analyze clean, 141 tests/2 skipped, Play profile 11/1 skipped, native Linux 1, signed release APK and AAB/16KB checks. Exact run/artifact links are recorded in `docs/playstore/VALIDATION.md`. Physical-device, billing and publication acceptance remain external gates. Documentation-only commits after that SHA do not alter tested runtime/workflows. PR4 remains unmerged; use canonical branch.

Handoff: record commit/version, changed files, exact root causes/fixes, schema impact, tests/build evidence, device result and remaining external activation gates. Never describe a preparation AAB as published or a mocked payment test as a real purchase.
