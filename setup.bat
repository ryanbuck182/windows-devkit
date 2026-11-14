@echo off
powershell -NoProfile -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -ErrorAction SilentlyContinue"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build.ps1" || exit /b 1
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0dist\devkit-install.ps1" "%~dp0."
