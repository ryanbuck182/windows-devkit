# Generates batch wrappers for the powershell commands

$commandDir = Join-Path $PSScriptRoot "..\src\powershell\commands"
$wrapperDir = Join-Path $PSScriptRoot "..\build\bat-wrappers"
$runPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\src\cmd\run.ps1"))

# Create dir if doesn't exist
[System.IO.Directory]::CreateDirectory($wrapperDir) | Out-Null

# Clear wrappers
Get-ChildItem -Path $wrapperDir -File | Remove-Item

# Function to build the wrapper content
# setlocal keeps DEVKIT_COMMAND from staying set in the cmd window
function New-WrapperContent($commandName) {
return @"
:: Wrapper for the $commandName command
@echo off
setlocal
set "DEVKIT_COMMAND=$commandName"
powershell -NoProfile -ExecutionPolicy Bypass -File "$runPath" %*
"@
}

# Create wrappers
Get-ChildItem -Path $commandDir -Filter *.ps1 | ForEach-Object {
    $commandName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

    $wrapperContent = New-WrapperContent $commandName
    $wrapperPath = Join-Path $wrapperDir "$commandName.bat"

    Set-Content -Path $wrapperPath -Value $wrapperContent
}

# TODO: Move everything following this to somewhere else

# Have to do something special for xx cause exit is a keyword not a command
Set-Content -Path (Join-Path $wrapperDir "xx.bat") -Value @"
:: Alias for exit
@echo off
exit
"@

Set-Content -Path (Join-Path $wrapperDir "tpx.bat") -Value @"
:: Alias for tp + exit
@echo off
call tp
:: Give the new tab time to open before closing this one
timeout /t 1 /nobreak > nul
exit
"@
