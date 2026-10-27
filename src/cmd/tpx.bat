:: Alias for tp + exit
:: exit has to run in cmd itself, so this replaces the generated wrapper
@echo off
call tp
:: Give the new tab time to open before closing this one
timeout /t 1 /nobreak > nul
exit
