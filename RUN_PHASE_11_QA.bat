@echo off
setlocal
cd /d "%~dp0"
echo === FINCHAT PHASE 11 QA ===
call flutter pub get
if errorlevel 1 goto :fail
call flutter analyze
if errorlevel 1 goto :fail
call flutter test
if errorlevel 1 goto :fail
call flutter build apk --release
if errorlevel 1 goto :fail
echo.
echo Automated Phase 11 checks completed successfully.
echo Device verification is still required using docs\PHASE_11_7_E2E_MATRIX.md.
goto :done
:fail
echo.
echo Phase 11 QA stopped because one command failed.
exit /b 1
:done
exit /b 0
