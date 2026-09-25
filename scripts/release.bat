@echo off
setlocal
where git >nul 2>&1 || (echo Git tidak ditemukan.& exit /b 1)
if not exist .git (echo Bukan repository Git.& exit /b 1)
git status --porcelain
if not errorlevel 0 exit /b 1
set /p TAG=Masukkan tag release (contoh v0.1.0):
if not defined TAG exit /b 1
git tag "%TAG%"
git push origin "%TAG%"
