@echo off
setlocal
where git >nul 2>&1 || (echo Git tidak ditemukan.& exit /b 1)
if not exist .git (echo Bukan repository Git.& exit /b 1)
echo === FinChat Git Status ===
git branch --show-current
git remote -v
git status
 echo.
git log --oneline -5
