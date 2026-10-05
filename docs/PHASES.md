# FinChat Phases

## Current patch — 0.3.2+11 (2026-10-05)

Authoritative current audit: `AUDIT_0.3.2+11.md`. Fixes RouterDelegate navigatorKey/system Back, CI FFI factory setup, integrated local/AI questions, money-in-question routing, guarded camera/file pickers, voice cancel callbacks, Google Drive snapshot acknowledgements, bottom navigation reports and shared smart period filter. Transaction cards use gestures only; white rounded composer includes emoji/attachment/camera/mic/send.

SQLite schema and existing workflows unchanged. Source is matched to main commit `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Flutter SDK unavailable locally; CI and real Android device acceptance are required. Baseline CI had 72 passed / 1 failed (global FFI factory test setup); do not describe the baseline result as verification of this patch.


## Roadmap status

1. Product Definition & Repository Foundation — **completed baseline**.
2. Flutter Foundation — **CI/build completed**; secure session carry-over is now completed in Phase 10.
3. Transaction Engine — **parser baseline completed**.
3B. Local Database + Transaction Repository + Category Learning — **completed baseline**.
4. AI Fallback — **service/contract baseline completed**; real provider and financial Q&A remain backlog.
5. Receipt/OCR & image preprocessing — **technical baseline completed**; Phase 11.2 vertical integration is implemented and test-verified.
6. Voice input — **technical baseline completed**; Phase 11.3 UI integration is implemented, with device acceptance deferred to final Phase 11 QA.
7. Reports and analytics — **report baseline completed**; Phase 11.4 integration now implements charts/interactive details.
8. PDF export — **baseline completed**.
9. Backup & Google Drive sync — **provider baseline completed**; Phase 11.5 implements local backup UI, Google OAuth wiring and Drive sync UX. Automatic execution remains an explicit verification/hardening item.
10. Update & Release — **completed**.
11. QA & End-to-End Integration — **CI/release verified; device acceptance pending**.
12. Production Hardening — **implemented 12.1–12.8; CI/device acceptance pending**.

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


### Phase 11.2 Receipt/OCR — IMPLEMENTED; DEVICE VERIFICATION PENDING

The vertical slice now connects camera/gallery input to the existing preprocessing and ML Kit OCR services, parses multiple receipt line items, presents a review/edit screen, learns category corrections, and persists reviewed transactions to SQLite. Device permission/error handling and release/device verification remain acceptance work.


## Phase 11.3 — Voice transaction integration — IMPLEMENTED; DEVICE VERIFICATION PENDING

Implemented vertical integration:
- microphone button in the transaction composer;
- Indonesian `id_ID` speech recognition;
- listening/stopping/error state feedback;
- transcript routed through the same `TransactionIntelligenceService` as text input;
- multi-transaction voice input supported by the existing parser;
- voice transactions persist with `InputSource.voice`;
- voice service now exposes change notifications for UI state;
- service test verifies UI notifications and Indonesian locale propagation.

Device microphone permission and physical-device acceptance are intentionally deferred until the final Phase 11 end-to-end test cycle.


## Phase 11.4 — Reports/PDF
Implemented: arbitrary day selection, date-range selection, month/year selection, summary metrics, expense-category aggregation, transaction-count visualization, insight card, drill-down to matching transactions, empty/loading/error states, and enhanced PDF category summary.

## Phase 11.5 — Backup/Google Drive
Implemented: local JSON export/import, restore confirmation, Google Sign-In authorization, Drive `appDataFolder` provider wiring, status/error UX, and persisted automatic-backup preference. Actual automatic execution is not claimed until device/network verification and a safe trigger policy are accepted.

## Phase 11.6 — AI
Implemented: concrete OpenAI-compatible provider behind the existing `AiCategoryProvider` contract, secure configuration, local-first category classification, malformed/offline fallback, and financial Q&A using application-computed report data. AI does not write SQLite.

## Phase 11.7 — End-to-End QA
QA tooling and matrix are implemented. The project owner has verified the cumulative package through analyze, tests, and release APK. Real-device execution remains pending and is intentionally scheduled after Phase 12 hardening.


## Phase 12 gate
Phase 12 engineering may proceed after the Phase 11 code path reaches Analyze, Tests, and Release-build verification. Device verification remains the final product-acceptance gate and is not claimed by this package.

### Phase 11 CI correction
After the 11.4–11.7 cumulative merge, analyzer cleanup was required for integration imports, an unused Drive import, report-screen syntax, and tests aligned to the current report/AI contracts. This is a CI stabilization step; feature scope is unchanged.


## PHASE 12 — Production Hardening
12.1 Stability & Crash Hardening
12.2 Data Integrity
12.3 AI Reliability & Safety
12.4 Performance
12.5 Security
12.6 UX Resilience
12.7 Release Hardening
12.8 Final Product Acceptance

Delivered as one cumulative package while retaining separate sub-phase scope.

## Phase 12 account and monetization foundation
Added Google Sign-In session integration and the disabled foundation for four subscription tiers and multiple payment methods. Monetization remains OFF during pilot testing. Google OAuth and backend verification are device/configuration gates, not claimed by source-level CI.
