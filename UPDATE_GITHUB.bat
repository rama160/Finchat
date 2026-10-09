@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

title FinChat - GitHub Update and Cleanup
set "REMOTE_URL=https://github.com/rama160/Finchat"
set "BRANCH=spenva-source-of-truth"
set "COMMIT_MESSAGE=%~1"
if "%COMMIT_MESSAGE%"=="" set "COMMIT_MESSAGE=FinChat audit cleanup and repository sync"

echo ============================================================
echo FinChat - GitHub Update and Cleanup
echo ============================================================
echo Folder : %CD%
echo Remote : %REMOTE_URL%
echo Branch : %BRANCH%
echo.
echo Script ini menjadikan isi folder ini sebagai sumber update repo.
echo File tracked yang sudah tidak ada di folder akan ikut DIHAPUS dari GitHub.
echo Tidak menggunakan force-push.
echo.

where git >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Git tidak ditemukan di PATH.
  exit /b 1
)

if not exist ".git" (
  echo [INFO] Repository Git lokal belum ada. Membuat repository...
  git init || exit /b 1
  git branch -M %BRANCH% || exit /b 1
  git remote add origin "%REMOTE_URL%" || exit /b 1
  git fetch origin %BRANCH% || exit /b 1
  git reset --mixed origin/%BRANCH% || exit /b 1
) else (
  git remote get-url origin >nul 2>&1
  if errorlevel 1 (
    git remote add origin "%REMOTE_URL%" || exit /b 1
  ) else (
    git remote set-url origin "%REMOTE_URL%" || exit /b 1
  )

  set "HAS_CHANGES="
  for /f "delims=" %%A in ('git status --porcelain') do set "HAS_CHANGES=1"
  if defined HAS_CHANGES (
    echo [INFO] Menyimpan perubahan lokal sementara sebelum sinkronisasi remote...
    git stash push -u -m "finchat-auto-sync-temp" >nul 2>&1 || exit /b 1
  )

  git fetch origin %BRANCH% || exit /b 1
  git checkout %BRANCH% >nul 2>&1
  if errorlevel 1 exit /b 1
  git pull --rebase origin %BRANCH%
  if errorlevel 1 (
    echo [ERROR] Pull/rebase gagal. Selesaikan conflict secara manual. Tidak ada push dilakukan.
    exit /b 1
  )

  if defined HAS_CHANGES (
    git stash pop
    if errorlevel 1 (
      echo [ERROR] Konflik saat mengembalikan perubahan lokal. Selesaikan conflict secara manual.
      exit /b 1
    )
  )
)

echo.
echo [INFO] Membersihkan hanya file instruksi lama yang sudah dikonsolidasi...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $legacy=@('PHASE_11_2_COPY_INSTRUCTIONS.md','PHASE_11_3_COPY_INSTRUCTIONS.md','PHASE_11_4_COPY_INSTRUCTIONS.md','PHASE_11_5_COPY_INSTRUCTIONS.md','PHASE_11_6_COPY_INSTRUCTIONS.md','PHASE_11_7_COPY_INSTRUCTIONS.md','PHASE_12_COPY_INSTRUCTIONS.md'); foreach($p in $legacy){ if(Test-Path -LiteralPath $p){ Remove-Item -LiteralPath $p -Force } }"
if errorlevel 1 exit /b 1

echo [INFO] Mendeteksi file baru, berubah, dan file yang harus dihapus...
git add -A || exit /b 1

git diff --cached --quiet
if not errorlevel 1 (
  echo [INFO] Tidak ada perubahan untuk dikirim ke GitHub.
  git status --short
  goto PUSH
)

echo.
echo [INFO] Perubahan yang akan dikirim:
git diff --cached --name-status

echo.
git commit -m "%COMMIT_MESSAGE%" || exit /b 1

:PUSH
echo [INFO] Push ke GitHub...
git push origin %BRANCH%
if errorlevel 1 (
  echo [ERROR] Push gagal. Commit lokal tetap aman dan tidak ada force-push.
  exit /b 1
)

echo.
echo ============================================================
echo [SUCCESS] GitHub berhasil diperbarui.
echo File lama yang sudah tidak ada di paket lokal ikut terhapus.
echo ============================================================
exit /b 0
