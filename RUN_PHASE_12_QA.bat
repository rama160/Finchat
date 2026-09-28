@echo off
setlocal
where flutter >nul 2>&1 || (echo Flutter SDK tidak ditemukan.& exit /b 1)
echo === FinChat Phase 12 QA ===
call flutter pub get || exit /b 1
call flutter analyze || exit /b 1
call flutter test || exit /b 1
call flutter build apk --release || exit /b 1
if exist build\app\outputs\flutter-apk\app-release.apk (certutil -hashfile build\app\outputs\flutter-apk\app-release.apk SHA256) else (echo APK release tidak ditemukan.& exit /b 1)
echo Phase 12 automated QA selesai. Device QA masih harus dilakukan.
