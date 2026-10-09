# Implementation status — Spenva 0.3.4+19

Current source and release authority: [SPENVA_CANONICAL_SOURCE.md](SPENVA_CANONICAL_SOURCE.md). Audit date: 9 October UTC / 10 October 2026 Asia/Makassar. Baseline canonical commit: `da61888d8151ee5bff52cea2a4cff846da8d5aa1`.

Implemented: persistent local/Google session; immediate multi-transaction local capture; voice normalization; camera/gallery/file receipt preprocessing and review; category corrections/learning; day/range/month report filters, pie and daily expense chart; PDF save/share; local/Drive restore; background authorized Drive backup; local financial questions with explicit period handling; pilot Gateway; disabled-until-configured Play subscription verification/quota/privacy/deletion flows; bundled offline branding/fonts.

+19 fixes: consistent transactional backup snapshots; UTF-8 import; strict snapshot identities/enums/types/references and insert-abort restore; router lifetime and account-keyed pages; Android plugins/property order and query merging; safe explicit cleanup; metadata/inventory CI guard; source-derived AAB version validation; configured Google server client ID in Play builds; stale external-payment test contract.

SQLite schema stays 1; no destructive migration, provider endpoint change, quota/price change, signing-secret change, subscription deployment or personal AI activation.

Verification: backend 46 tests, Android template 3 tests, publication validator 5 tests and plan-generator consistency pass locally. Dart formatting parses changed files. Local Flutter analyze/test/build unavailable because automatic review blocked a metadata-service access attempt. GitHub results for this exact patch are tracked in [playstore/VALIDATION.md](playstore/VALIDATION.md); exact tested source `2f8d47e642c835197ffd9786f0013d12a7f79d5d` passed analyze, 141 normal tests (2 skipped), 11 Play-profile tests (1 skipped), 1 native Linux integration, signed APK and AAB/16KB checks. Subsequent documentation-only commits preserve tested runtime/workflows. PR4 remains unmerged.

Remaining acceptance is external: Play-configured OAuth, physical camera/microphone/OCR/IME/PDF/Drive, real billing lifecycle and distributed Play build, publication identity/contact/URLs, backend bindings and provider setup, closed testing and Console review. No physical-device or real-purchase pass is asserted.
