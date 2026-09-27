@echo off
setlocal EnableExtensions EnableDelayedExpansion

title FinChat - Safe GitHub Uploader
color 0A

echo ============================================================
echo   FinChat - Safe GitHub Automatic Uploader
 echo ============================================================
echo.

where git >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Git tidak ditemukan. Install Git for Windows terlebih dahulu.
  goto :fail
)

if not exist ".git" (
  echo [1/8] Membuat repository Git lokal...
  git init
  if errorlevel 1 goto :fail
) else (
  echo [1/8] Repository Git lokal sudah ada.
)

for /f "delims=" %%R in ('git remote get-url origin 2^>nul') do set "REMOTE=%%R"
if not defined REMOTE (
  set /p "REMOTE=Masukkan URL repository GitHub: "
  if not defined REMOTE (
    echo [ERROR] URL repository wajib diisi.
    goto :fail
  )
  git remote add origin "!REMOTE!"
  if errorlevel 1 goto :fail
) else (
  echo [2/8] Remote origin: !REMOTE!
)

git branch -M main

echo [3/8] Mengecek status lokal...
git status --short

echo.

set /p "MSG=Pesan commit [Update FinChat]: "
if not defined MSG set "MSG=Update FinChat"

git add -A
if errorlevel 1 goto :fail

git diff --cached --quiet
if errorlevel 1 (
  echo [4/8] Membuat commit lokal...
  git commit -m "!MSG!"
  if errorlevel 1 goto :fail
) else (
  echo [4/8] Tidak ada perubahan baru untuk di-commit.
)

echo [5/8] Mengambil informasi remote...
git fetch origin main
if errorlevel 1 (
  echo [ERROR] Gagal mengambil branch main dari GitHub.
  goto :fail
)

set "REMOTE_EXISTS=0"
git show-ref --verify --quiet refs/remotes/origin/main
if not errorlevel 1 set "REMOTE_EXISTS=1"

if "!REMOTE_EXISTS!"=="1" (
  echo [6/8] Memeriksa hubungan history lokal dan remote...
  git merge-base --is-ancestor origin/main HEAD
  if not errorlevel 1 (
    echo Remote adalah ancestor lokal. Tidak perlu merge.
  ) else (
    git merge-base --is-ancestor HEAD origin/main
    if not errorlevel 1 (
      echo Remote lebih baru. Melakukan fast-forward lokal...
      git merge --ff-only origin/main
      if errorlevel 1 goto :fail
    ) else (
      echo [WARN] History lokal dan remote berbeda.
      echo [INFO] Menggabungkan history dengan --allow-unrelated-histories.
      echo [INFO] Tidak ada force push. Jika terjadi conflict, script berhenti.
      git merge origin/main --allow-unrelated-histories --no-edit
      if errorlevel 1 (
        echo.
        echo [STOP] Conflict merge terdeteksi.
        echo Selesaikan conflict secara manual, lalu jalankan kembali BAT ini.
        goto :fail
      )
    )
  )
) else (
  echo [6/8] Remote main belum ada. Push pertama akan dibuat.
)

echo [7/8] Push ke GitHub...
git push -u origin main
if errorlevel 1 goto :fail

echo [8/8] Selesai.
echo Repository berhasil disinkronkan tanpa force push.
echo GitHub Actions akan menjalankan analyze, test, dan build Android.
echo.
goto :success

:fail
echo.
echo ============================================================
echo   GAGAL - Lihat pesan Git di atas.
echo   Script TIDAK melakukan force push atau menghapus history.
echo ============================================================
exit /b 1

:success
exit /b 0
