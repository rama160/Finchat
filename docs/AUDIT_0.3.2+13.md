## Verified GitHub CI — 0.3.2+13 (5 Oktober 2026)

- Tested code commit `02ea7a394e0af7afaedc85db5f44bf1ccef4aec3`, branch `codex/finchat-input-navigation-audit`.
- Run https://github.com/rama160/Finchat/actions/runs/37301937885 — success. Flutter stable 3.47.6: dependency resolution passed; analyze No issues found; **100 tests passed**; signed release APK **92.2 MB** built.
- APK: https://github.com/rama160/Finchat/actions/runs/37301937885/artifacts/11341239451 . Signing keystore and Google server client ID retained; no secrets changed.
- Regressions: Mahkota separate/noisy/column OCR and plain prices; exact keyword nota with zero AI calls; persistent typed categories and learning; inline save status; delete cancellation/confirmation; two-day comparison across year boundary; existing speech/token/Drive/storage/navigation tests.
- Gateway recovery snapshot: https://github.com/rama160/Finchat/actions/runs/37302216708 — npm ci, typecheck, lint, **17 tests** and Wrangler dry-run passed. Full corrected backend plus exact tested lockfile is included in the ZIP's separate AI-Gateway folder.
- GitHub write to rama160/AI-Gateway was rejected HTTP403 Resource not accessible by integration. No Gateway repo update or Cloudflare deployment occurred; live HTTP503 is not claimed resolved. Its main remains b7769af739b1550667c5a75e524d3d62e8f8a324.
- Finchat main remains 91252bddf4a4eadaa99dafe095f72c2e04a4bab1. Original three workflows, SQLite schema/lifecycle, money parser and transaction repository are byte-identical. Temporary backend snapshot validation is isolated in `codex/gateway-recovery-validation`; source ZIP retains the original workflow files.
- First run stopped on a redundant assertion warning, corrected. Second run exposed duplicate IDs caused by the test's frozen clock; its second input now advances the clock. Final suite and signed build passed. No product transaction-ID contract change.
- **Device/live gate open:** actual camera/attach OCR quality, Google/Gemini/Drive and report chart on Android must be retested. The fixture yields three products/Rp69.059; it is not a claim of real-device OCR success.
- This section supersedes older “verification pending” entries below. Final docs-only follow-up does not alter tested application code.

## Device receipt follow-up — 0.3.2+13 (5 Oktober 2026)

- Receipt parser joins product names with quantity/price rows, restores OCR column reading order from image coordinates, and excludes payment/header/footer rows. Mahkota Mart fixture: 3 items, Rp69.059; no payment or change recorded.
- Save success appears inline above the composer. Swipe delete requires explicit Hapus confirmation; Batal preserves data.
- Category edit accepts typed names and existing choices, persists custom categories without schema migration, and reuses the existing per-user correction learning.
- Single-day chart compares the previous day and selected day. Summary, pie and PDF retain the selected period only; date ranges/months retain daily buckets.
- Exact question “berapa total pengeluaran dengan kata acara, buat dalam bentuk nota” is answered locally from matching descriptions; it no longer requires Gateway.
- AI 503 remains an upstream operational issue until a corrected Gateway is deployed and tested against the real provider. Android OCR quality/camera/attach still requires device validation.
- Verification pending GitHub analyze/tests/signed APK. Original workflows, schema, database lifecycle, money parser and transaction repository retained.

Regression gates: Mahkota split/noisy/geometry/plain price OCR; exact local keyword question; custom category persistence/isolation; delete cancel/confirm and learned input UI; non-overlay save status; date boundary comparison and existing full suite.
