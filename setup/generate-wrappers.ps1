# Generates batch wrappers for the powershell commands

$commandDir = Join-Path $PSScriptRoot "..\src\powershell\commands"
$wrapperDir = Join-Path $PSScriptRoot "..\build\bat-wrappers"
$cmdDir = Join-Path $PSScriptRoot "..\src\cmd"
$runPath = [System.IO.Path]::GetFullPath((Join-Path $cmdDir "run.ps1"))

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

# Some commands have their own batch version, which replaces the generated wrapper
Copy-Item -Path (Join-Path $cmdDir "*.bat") -Destination $wrapperDir -Force
