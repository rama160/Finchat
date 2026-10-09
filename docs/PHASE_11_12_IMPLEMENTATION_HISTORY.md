> Current source status: **0.3.4+19**, 9 October 2026 UTC. See [SPENVA_CANONICAL_SOURCE.md](SPENVA_CANONICAL_SOURCE.md) and the current detailed audit. Older version/build statements below are historical evidence and do not verify this patch.

# Phase 11–12 Implementation / Copy History

Dokumen ini menggabungkan instruction files lama yang sebelumnya tercecer di root repository. Isinya dipertahankan sebagai riwayat implementasi; status aktual harus mengacu ke `IMPLEMENTATION_STATUS.md` dan `FULL_REPOSITORY_AUDIT.md`.

=====PHASE_11_2_COPY_INSTRUCTIONS.md=====
# FinChat Phase 11.2 — Receipt/OCR

Copy the contents of this package into the existing Git-marked FinChat repository, preserving the folder structure. Replace existing files when prompted.

After copying:
1. Run `flutter pub get` (or let GitHub Actions run it).
2. Push the changes to GitHub.
3. Let GitHub Actions run `flutter analyze`, `flutter test`, and release APK build.
4. Install the release APK on an Android device and verify camera/gallery permission, OCR, multi-item review, edit/category correction, and SQLite persistence.

This package does not contain `.git` and does not replace the repository history. No database schema migration is included.

=====PHASE_11_3_COPY_INSTRUCTIONS.md=====
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

=====PHASE_11_4_COPY_INSTRUCTIONS.md=====
# Phase 11.4 Copy Instructions

Copy the contents of this package into the existing FinChat repository and allow overwrite.

Changed areas: `lib/domain/reports`, `lib/application/reports`, `lib/presentation/screens/report_screen.dart`, report tests, and roadmap/status documentation.

Then run:
```text
flutter analyze
flutter test
```
Device PDF/report testing is intentionally postponed until Phase 11.7.

=====PHASE_11_5_COPY_INSTRUCTIONS.md=====
# Phase 11.5 Copy Instructions

Copy package contents into the existing FinChat repository and allow overwrite.

Run:
```text
flutter pub get
flutter analyze
flutter test
```

Before device testing, configure Google Cloud OAuth as described in `docs/GOOGLE_ACCOUNT_AND_DRIVE_SETUP.md`. Device verification remains part of Phase 11.7.

=====PHASE_11_6_COPY_INSTRUCTIONS.md=====
# Phase 11.6 Copy Instructions

Copy package contents into the existing FinChat repository and allow overwrite.

Run:
```text
flutter pub get
flutter analyze
flutter test
```

AI remains optional. Do not put API keys into source code, Git, README, or SQLite. Configure them from Settings after installation.

=====PHASE_11_7_COPY_INSTRUCTIONS.md=====
# Phase 11.7 Copy Instructions

Copy package contents into the existing FinChat repository and allow overwrite.

Run automated verification:
```text
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Historical note: the old `RUN_PHASE_11_QA.bat` has been retired; use GitHub Actions for QA and `UPDATE_GITHUB.bat` for repository synchronization.

Then execute `docs/PHASE_11_7_E2E_MATRIX.md` on the real Android device. Do not mark Device verified or Product accepted until the real-device run is complete.

=====PHASE_12_COPY_INSTRUCTIONS.md=====
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

