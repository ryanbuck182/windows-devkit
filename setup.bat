@echo off
powershell -NoProfile -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -ErrorAction SilentlyContinue"
powershell -NoProfile -Command "if ((Get-ExecutionPolicy) -in 'Restricted','AllSigned') { Write-Warning 'Unable to set the execution policy to RemoteSigned. Devkit commands will not load in powershell.' }"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup\setup.ps1" %*
