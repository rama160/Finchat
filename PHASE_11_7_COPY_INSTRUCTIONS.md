# Phase 11.7 Copy Instructions

Copy package contents into the existing FinChat repository and allow overwrite.

Run automated verification:
```text
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Or on Windows run `RUN_PHASE_11_QA.bat`.

Then execute `docs/PHASE_11_7_E2E_MATRIX.md` on the real Android device. Do not mark Device verified or Product accepted until the real-device run is complete.
