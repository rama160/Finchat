# AI START HERE — FINCHAT

## Current patch — 0.3.2+11 (2026-10-05)

Authoritative current audit: `docs/AUDIT_0.3.2+11.md`. Fixes RouterDelegate navigatorKey/system Back, CI FFI factory setup, integrated local/AI questions, money-in-question routing, guarded camera/file pickers, voice cancel callbacks, Google Drive snapshot acknowledgements, bottom navigation reports and shared smart period filter. Transaction cards use gestures only; white rounded composer includes emoji/attachment/camera/mic/send.

SQLite schema and existing workflows unchanged. Source is matched to main commit `91252bddf4a4eadaa99dafe095f72c2e04a4bab1`. Flutter SDK unavailable locally; CI and real Android device acceptance are required. Baseline CI had 72 passed / 1 failed (global FFI factory test setup); do not describe the baseline result as verification of this patch.


## Current continuation point — Bugfix package 0.3.2+10

Read this file first, then:
1. `docs/FULL_REPOSITORY_AUDIT.md`
2. `docs/FINCHAT_MASTER_CONTEXT.md`
3. `docs/PRD.md`
4. `docs/ARCHITECTURE.md`
5. `docs/PHASES.md`
6. `docs/AI_CONTRACT.md`
7. `docs/IMPLEMENTATION_STATUS.md`
8. `CHANGELOG.md`
9. actual source code

## Current truth

- Technical work exists through Phase 12 hardening.
- This package fixes two device-reported runtime regressions without changing the established product workflow: `DatabaseException(error database_closed)` during text/voice/receipt transaction capture, and AI Gateway fallback being disabled by the legacy local `ai.enabled` gate.
- Production `FinChatDatabase()` instances now share one application database handle; screen-level `dispose()` calls no longer close that shared production connection. Custom database factory/path instances remain isolated for tests.
- The database open path is serialized and reopens a handle if the cached handle is no longer open.
- The AI provider is Gateway-first in production. It reuses the existing `GoogleSignInCoordinator` session configuration to obtain the logged-in Google ID token, then calls the Cloudflare Gateway. Gemini API credentials remain server-side. The legacy local AI enable switch is retained only when an `AiSecureConfigService` is explicitly injected, preserving existing test/config contracts.
- Google Sign-In and restore/migration behavior are intentionally left unchanged.
- Flutter/Dart SDK is not available in the artifact workspace, so local analyze/test/APK build is not claimed. A GitHub Actions run exposed analyzer-only issues in the AI provider/test fixture; those issues are fixed in 0.3.2+7. GitHub Actions remains the canonical verification environment.
- Real Android-device acceptance is still required for camera, microphone, OCR quality, Google Sign-In/OAuth, Google Drive and Gateway/AI behavior.

## Non-negotiable product rules

- Offline-first; SQLite is the source of truth.
- Local parser/category history first; AI only as fallback/support.
- AI never writes directly to SQLite.
- Text/voice transactions save immediately when recognized.
- Saved transactions expose swipe right to edit and swipe left to delete; no edit/delete buttons on transaction rows.
- User category corrections must be learned locally.
- Receipt images are preprocessed/compressed before OCR and reviewed before persistence.
- Common financial questions are answered from application-computed local report data before AI fallback.
- Automatic Drive backup requires one-time Google authorization; once enabled it is attempted on app load/data changes and must not block transaction capture.
- Every meaningful change updates changelog/status/audit documentation.
- Never force-push automatically.

## 0.3.2+8 analyzer follow-up

GitHub Actions reported two analyzer errors remaining in `lib/data/ai/openai_compatible_ai_provider.dart` after 0.3.2+7. They are fixed in this package:

- The optional `idTokenProvider` callback is now assigned through an initialized private final field in the constructor, removing `final_not_initialized_constructor`.
- `_chat()` copies the nullable callback into a local `tokenProvider` before invocation, so the non-null branch is promoted and `unchecked_use_of_nullable_value` is removed.
- No production workflow or business logic was changed.
- The Gateway endpoint, Google Sign-In coordinator, database lifecycle fix, restore flow, OCR, voice, transaction parsing, reports, backup, and GitHub workflow remain unchanged.


- Fixed `prefer_initializing_formals` in `OpenAiCompatibleAiProvider` without changing the public constructor argument `idTokenProvider` or Gateway behavior.
- Removed the unnecessary non-null assertion when invoking the injected ID-token provider.
- Rewrote the Gateway JSON test fixture with `jsonEncode()` so analyzer no longer reports unnecessary string escapes.
- No database, authentication, restore/migration, transaction, OCR, voice, report, backup, Gateway endpoint, or GitHub workflow logic was changed.

## Exact next gate

1. Run `UPDATE_GITHUB.bat` from the package root.
2. Confirm GitHub Actions passes `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --release`.
3. Fix any CI issue against this exact package without reverting the audit goals.
4. Perform the device acceptance matrix in `docs/FULL_REPOSITORY_AUDIT.md` and `docs/PHASE_12_HARDENING_MATRIX.md`.

## Handoff requirement

At the end of each patch, record current version, changed files, exact issue, exact fix, schema/data impact, tests/CI result, device result, and any remaining PRD gap.

### 0.3.2+9 analyzer follow-up
The CI analyzer reported two remaining errors in `openai_compatible_ai_provider.dart`. The constructor now uses an initializing formal for `_idTokenProvider`, and token-provider invocation uses explicit nullable-flow promotion. No existing workflow or business logic was changed.

### 0.3.2+10 database test follow-up
GitHub Actions reported one failing test after the analyzer fixes: `test/data_database_test.dart` failed with `Bad state: databaseFactory not initialized`. The cause was eager initialization of the static production `FinChatDatabase` singleton, which evaluated the global `databaseFactory` before `sqflite_common_ffi` test setup ran.

Fix: `FinChatDatabase._shared` is now a lazy getter backed by `_sharedInstance`. The global `databaseFactory` is therefore not read until the first production `FinChatDatabase()` call. This preserves the established production shared-connection behavior and `close()` protection, while allowing `setUpAll(sqfliteFfiInit)` to initialize the FFI factory first. No schema, business logic, restore flow, Google Sign-In, OCR, voice, AI Gateway, or GitHub workflow was changed.

Verification status: source-level fix prepared from CI failure. Run the canonical GitHub Actions sequence again: `flutter analyze`, `flutter test`, then release APK build.
