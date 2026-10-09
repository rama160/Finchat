# Spenva (FinChat repository)

Offline-first Android personal finance app with local text/voice/receipt capture, category learning, reports/PDF, Google login and optional Drive backup. Public name: Spenva; internal package/application ID remain compatible with FinChat.

Current source: **0.3.4+19** on `spenva-source-of-truth`. The old `main` baseline and predecessor branches must not be used for a new build until the canonical integration has been merged. Read [Ai start here.md](Ai%20start%20here.md), [canonical product decisions](docs/SPENVA_CANONICAL_SOURCE.md) and [detailed audit](docs/FULL_REPOSITORY_AUDIT.md).

The latest patch fixes snapshot consistency/validation, UTF-8 backup import, router lifetime/logout isolation, Android template configuration and unsafe cleanup. Existing logo, input UX, Google/session identity, SQLite schema, receipt review, category learning and quota matrix are preserved.

Validation uses GitHub Actions: Flutter analyze/tests, signed pilot APK, separate Play-profile tests, native Linux integration, screenshot capture and signed AAB/16KB verification. [Current evidence and limits](docs/playstore/VALIDATION.md) separates this patch from historical successful builds.

Windows synchronization: run `UPDATE_GITHUB.bat`. It targets the canonical integration branch, stages additions/updates/deletions, uses no force push and removes only explicitly obsolete phase instructions. Unknown files are retained. Do not run an older BAT from an old ZIP over current source.

Free/Plus/Pro/Max prices and quotas have one source: [subscription_plans.json](assets/config/subscription_plans.json); check generated Dart/server definitions with `python3 tooling/play/generate_subscription.py --check`. Payment uses Google Play Billing; external checkout is disabled. Subscription server and paid personal AI remain inactive until separately configured and verified. Core pilot functionality remains available.

Play publication still requires real publisher/contact/URLs, signed Play OAuth testing, backend setup if metered features are enabled, device acceptance, closed testing and Console review. See [launch](docs/playstore/LAUNCH.md), [subscription](docs/playstore/SUBSCRIPTION.md), [privacy/data](docs/playstore/DATA_SAFETY.md).
