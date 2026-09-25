# Changelog

## 0.1.0-phase2-v2 — 2026-09-25

### Type
Phase 2 foundation correction / CI and Git automation.

### Component
Flutter project structure, GitHub Actions, Windows upload automation, documentation.

### Previous problem / behavior
- The previous package did not provide a reliable GitHub-only Android build path when the `android/` platform folder was absent.
- The previous uploader stopped when local and remote `main` histories were unrelated, requiring manual `git pull --rebase`, which is not appropriate for unrelated initial commits.
- Local Flutter was unavailable, so local CLI verification could not be claimed.

### Exact change
- Added GitHub Actions test workflow using Flutter stable.
- Added Android build workflow with automatic `flutter create --platforms=android` when `android/` is missing.
- Added release workflow with the same Android bootstrap behavior.
- Replaced the uploader logic with a non-destructive history-aware flow: fetch, detect ancestor relationship, fast-forward when possible, otherwise merge with `--allow-unrelated-histories`; stop on conflicts; never force push.
- Added `.gitattributes` for predictable line endings.
- Added project continuation and implementation documentation.

### Reason
Allow the user to develop/build FinChat through GitHub without requiring a local Flutter installation while protecting existing GitHub history.

### Impact
- User can upload with `UPLOAD_TO_GITHUB.bat` even when GitHub already contains an initial commit.
- GitHub Actions can create Android platform files on the runner and build the APK.
- A merge conflict still requires human resolution; the script does not guess or overwrite files.

### Migration
Replace the old package with this package, or copy the new uploader/workflows/docs into the existing repository. If the local repository already has the old uploader, replace it with this version.

### Tests
Local Flutter `analyze/test/build` were not executed because Flutter SDK is not installed in the current build environment. CI workflows are configured to perform those checks on GitHub.

### Result
Implementation prepared; real CI result remains the source of truth after push.

### Status
Phase 2 remains active. Next: persistent secure session, local DB, migrations, real repositories.
## 0.1.0+2 — 2026-09-25

- **Type:** Fix / compatibility
- **Component:** `lib/presentation/navigation/app_router.dart`
- **Previous problem:** GitHub Actions `flutter analyze` failed because the router used deprecated `RouteInformation.location` and `Navigator.onPopPage`, plus a null-aware expression that could never execute.
- **Exact change:** Migrated route information handling to `RouteInformation.uri`; replaced `Navigator.onPopPage` with `Navigator.onDidRemovePage`; removed the obsolete null-aware expression.
- **Reason:** Current Flutter stable analysis treats these deprecated APIs as analyzer issues, and the CI workflow is configured to fail when analysis reports issues.
- **Impact:** The router remains functionally equivalent for the current single-root-page navigation model while using the current Flutter navigation APIs.
- **Migration:** No database or user-data migration required. Replace the router file and rerun GitHub Actions.
- **Tests:** `flutter analyze` is expected to be clean in GitHub Actions; local Flutter SDK is not available in the authoring environment.
- **Result:** Pending GitHub Actions verification.
- **Status:** Fixed in source package; CI verification pending.


## 0.2.0 — 2026-09-25 — Phase 3 Transaction Engine foundation

- **Type:** feature
- **Component:** local transaction parsing / amount recognition
- **Previous behavior:** Phase 2 only contained transaction domain contracts; no production local parser existed.
- **Change:** added `MoneyAmountParser` and `LocalTransactionParser`.
- **Amount formats:** `25 rb`, `25 ribu`, `25k`, `Rp 25.000`, `Rp25.000`, `1 juta`, `1,5 juta`, `1.5jt`, `2m`, and grouped Indonesian amounts such as `1.250.000`.
- **Multi-transaction:** one text input can yield multiple parsed transactions when multiple money expressions are present.
- **Reason:** Indonesian users commonly write monetary amounts using informal shorthand; parser behavior must be deterministic and offline-first before AI fallback.
- **Impact:** transaction text input now has a local parsing foundation and test coverage for common amount representations.
- **Migration:** none.
- **Tests:** added unit tests for money normalization and local transaction parsing.
- **Result:** pending GitHub Actions verification.
- **Status:** in progress — Phase 3 foundation.
