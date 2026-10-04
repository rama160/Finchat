### Phase 11.1.2 CI fix — file_picker 13 API
`ChatScreen` now uses the `file_picker` 13 API (`FilePicker.pickFiles()` and `PlatformFile.readAsBytes()`) instead of the removed `FilePicker.platform`/`withData` pattern. Attachment receipt behavior is unchanged.

# FinChat Implementation Status

**Version:** 0.3.2+6  
**Status date:** 2026-10-05  
**Current stage:** Post-Phase-12 runtime bugfix; fresh CI + real-device acceptance pending.


## Runtime bugfix 0.3.2+6

- Fixed the shared SQLite lifecycle issue behind `DatabaseException(error database_closed)` during text, voice and receipt capture by making the default production database instance application-shared and preventing screen `dispose()` from closing it.
- Added serialized database opening and stale-handle recovery without changing schema or restore/migration behavior.
- Fixed Gateway AI availability by removing the legacy local `ai.enabled` prerequisite from the normal production provider path.
- AI now reuses the existing `GoogleSignInCoordinator` to obtain the current Google ID token before calling the existing Cloudflare Gateway.
- Gemini credentials remain server-side.

## Verified historical baseline

The project owner reported successful GitHub Actions for the earlier cumulative Phase 12 package. That historical result does not automatically verify this audit package because source, workflows, documentation and version metadata changed.

## Implemented product paths

- Persistent secure session with local email test mode and Google Sign-In integration.
- Text and voice transaction capture through local parser/category learning, immediate SQLite persistence, Edit/Delete actions and swipe gestures.
- Indonesian amount shorthand parsing and multi-transaction extraction.
- Camera/gallery receipt OCR with image preprocessing, multi-item extraction, review/edit and SQLite persistence.
- Explicit image-file receipt attachment (JPG/JPEG/PNG/WEBP) added by the repository audit.
- Daily/range/month reports, income/expense totals, balance, transaction grouping, insight, category pie chart, per-category transaction counts, drill-down and PDF sharing.
- Local-first financial Q&A for common totals/saldo/count/top-category questions, with OpenAI-compatible AI only for questions not resolved locally.
- Versioned local backup/restore, Google Drive appDataFolder backup/restore and automatic backup after one-time Drive authorization.
- Secure AI configuration, HTTPS/network hardening and provider contract.
- GitHub Releases update checker and release workflow.
- Free/Basic/Pro/Unlimited monetization domain foundation remains disabled during pilot.

## Repository cleanup in 0.3.2+5

- Removed `.git` from the distributable ZIP.
- Consolidated seven root phase copy-instruction files into `docs/PHASE_11_12_IMPLEMENTATION_HISTORY.md`.
- Replaced multiple GitHub/QA BAT files with one `UPDATE_GITHUB.bat` for additions, updates and deletions.
- Consolidated duplicated Android CI mutation logic into `tooling/android/configure_android_ci.py`; build and release workflows now use the same R8/minSdk/permission settings.
- Added `docs/FULL_REPOSITORY_AUDIT.md` as the authoritative file-by-file audit and acceptance matrix.

## Remaining verification gates

### GitHub Actions — required for this exact package
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --release`

### Real Android device — still required
- Google Sign-In and persistent session.
- Voice microphone permission, Indonesian recognition and multi-transaction save.
- Camera and explicit image-file receipt attachment.
- OCR on clear, blurred and multi-item receipts.
- Edit/Delete buttons and swipe gestures.
- Report pie chart, category counts, income/expense drill-down and PDF sharing.
- Local backup export/import.
- Google Drive authorization, manual backup/restore and automatic backup.
- Financial questions entered directly in the main chat composer.
- Update checker against an actual published GitHub Release.

No destructive SQLite schema migration is introduced by the 0.3.2+5 audit package or the 0.3.2+6 runtime bugfix.

### 0.3.2+9 analyzer follow-up
The CI analyzer reported two remaining errors in `openai_compatible_ai_provider.dart`. The constructor now uses an initializing formal for `_idTokenProvider`, and token-provider invocation uses explicit nullable-flow promotion. No existing workflow or business logic was changed.
