@echo off
setlocal
call "%~dp0..\UPLOAD_TO_GITHUB.bat"
exit /b %errorlevel%
