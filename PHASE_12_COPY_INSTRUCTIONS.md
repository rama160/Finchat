# Phase 12 Copy Instructions

1. Backup/commit repository Git Anda saat ini.
2. Extract seluruh isi ZIP Phase 12 ke folder repository FinChat yang sama.
3. Replace files when prompted.
4. Do not copy or create a new `.git` directory from this package; the package intentionally contains no `.git` directory.
5. Push the changes to GitHub.
6. Run GitHub Actions for `flutter analyze`, `flutter test`, and release APK build.
7. If CI fails, stop and send the complete error log before making additional changes.
8. If CI succeeds, install the resulting release APK and perform the complete device QA cycle for Phase 11 + Phase 12.

## Verification levels

This package is source-implemented and test-covered, but this build workspace does not contain the Flutter SDK. Therefore this package does not claim local `flutter analyze`, `flutter test`, release-build, or Android-device verification. The project owner's GitHub Actions result is the authoritative CI verification.
