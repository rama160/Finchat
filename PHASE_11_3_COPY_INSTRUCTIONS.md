# Phase 11.3 Voice — Copy Instructions

1. Extract this ZIP.
2. Copy the extracted contents into the existing FinChat Git repository.
3. Replace files when Windows asks.
4. Do not delete unrelated project files.
5. Push the changes to GitHub.
6. Let GitHub Actions run `flutter analyze`, `flutter test`, and the release build.
7. Do NOT perform physical microphone/camera acceptance yet. Device testing is intentionally deferred until all Phase 11 slices are complete.

Files added/changed by this package:
- `lib/application/speech/voice_input_service.dart`
- `lib/presentation/screens/chat_screen.dart`
- `test/application/speech/voice_input_service_test.dart`
- roadmap/status/handoff/changelog documentation

The chat screen contains the already test-verified Phase 11.2 OCR integration plus the new Phase 11.3 voice integration, so it can safely replace the current Phase 11.2 `chat_screen.dart`.
