# AI START HERE — FINCHAT

## Current continuation point — Repository audit package 0.3.2+5

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
- The project owner previously reported GitHub Actions success for the pre-audit Phase 12 baseline.
- This audit package changes source/build/docs and therefore **must receive a fresh GitHub Actions verification** before it is called CI-green.
- Flutter/Dart SDK is not available in the artifact workspace, so local analyze/test/APK build is not claimed.
- Real Android-device acceptance is still required for camera, microphone, OCR quality, file picker/share, Google Sign-In/OAuth, Google Drive and update-opening behavior.

## Non-negotiable product rules

- Offline-first; SQLite is the source of truth.
- Local parser/category history first; AI only as fallback/support.
- AI never writes directly to SQLite.
- Text/voice transactions save immediately when recognized.
- Saved transactions expose Edit/Delete; swipe right edits and swipe left deletes.
- User category corrections must be learned locally.
- Receipt images are preprocessed/compressed before OCR and reviewed before persistence.
- Common financial questions are answered from application-computed local report data before AI fallback.
- Automatic Drive backup requires one-time Google authorization; once enabled it is attempted on app load/data changes and must not block transaction capture.
- Every meaningful change updates changelog/status/audit documentation.
- Never force-push automatically.

## Exact next gate

1. Run `UPDATE_GITHUB.bat` from the cleaned package root.
2. Confirm GitHub Actions passes `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --release`.
3. Fix any CI issue against this exact package without reverting the audit goals.
4. Perform the device acceptance matrix in `docs/FULL_REPOSITORY_AUDIT.md` and `docs/PHASE_12_HARDENING_MATRIX.md`.

## Handoff requirement

At the end of each patch, record current version, changed files, exact issue, exact fix, schema/data impact, tests/CI result, device result, and any remaining PRD gap.
