# FinChat 0.3.2+6/+7 — Database Closed + AI Gateway Bugfix and Analyzer Cleanup

## User report

1. Text input, voice input and receipt capture fail with `DatabaseException(error database_closed)`.
2. AI is unavailable.
3. Existing Google Sign-In and legacy-data-to-current-data restore are already working and must not be changed.

## Root cause: SQLite lifecycle

`ChatScreen`, `ReportScreen`, `FinancialQaScreen` and `BackupScreen` each created `FinChatDatabase()` and called `close()` in their `dispose()` methods. The same physical SQLite file was therefore managed by multiple screen-owned handles. Async transaction/backup/report work could outlive a screen transition and encounter a closed handle.

### Fix

- Default production `FinChatDatabase()` returns one shared application instance.
- `close()` on the shared production instance is intentionally ignored so a child screen cannot close the application database.
- Test/custom instances created with a factory/path remain independent and can be closed normally.
- Concurrent opens are serialized.
- A cached handle that is no longer open is discarded and reopened.

No schema change or data migration was introduced. Existing restore behavior is unchanged.

## Root cause: AI Gateway

`OpenAiCompatibleAiProvider` still used the legacy `AiSecureConfigService.readEnabled()` gate. That local switch was designed for the old direct-provider model. The production app now uses the Cloudflare Gateway, but the provider still treated the legacy local flag as a prerequisite.

### Fix

- Production provider is Gateway-first when constructed normally.
- It obtains the Google ID token from the existing `GoogleSignInCoordinator`, so it uses the same configured Google session as login.
- It sends the token as `Authorization: Bearer <Google ID token>` to the existing Gateway endpoint.
- Gemini API key remains exclusively in the Gateway/server.
- Explicitly injected `AiSecureConfigService` is still honored so existing legacy tests/configuration contracts do not break.

## Preserved workflows

- Google Sign-In
- Existing local user identity mapping
- Restore/migration from old data to the current user
- Local parser before AI fallback
- Category learning
- OCR preprocessing and review
- Voice recognition
- Reports/PDF
- Backup/Google Drive
- GitHub Actions build workflow

## Files changed

- `pubspec.yaml` — version advanced to `0.3.2+7` for the analyzer cleanup follow-up.
- `lib/data/local/finchat_database.dart` — shared production connection, serialized open, stale-handle recovery.
- `lib/data/ai/openai_compatible_ai_provider.dart` — Gateway-first AI and shared Google Sign-In coordinator.
- `test/data_database_test.dart` — database lifecycle regression coverage.
- `test/data/openai_phase12_hardening_test.dart` — Gateway regression coverage.
- `Ai start here.md` — continuation point and current truth updated.
- `CHANGELOG.md` — bugfix entry.
- `docs/BUGFIX_0.3.2+6_DATABASE_AI.md` — detailed handoff.

## Follow-up 0.3.2+7 — analyzer cleanup

The first GitHub Actions analyzer run after the runtime bugfix reported eight issues, all non-runtime: one `prefer_initializing_formals`, one `unnecessary_non_null_assertion`, and six `unnecessary_string_escapes` in the Gateway regression test. These were fixed without changing the Gateway request contract or runtime workflow. The test now constructs its nested JSON with `jsonEncode()`.

## Verification gate

The artifact environment does not contain Flutter/Dart, so no local CI result is claimed. Run GitHub Actions: `flutter pub get`, `flutter analyze`, `flutter test`, and Android release build. Then install the generated APK and test text, voice, receipt, Google login and an AI fallback case on a real Android device.
