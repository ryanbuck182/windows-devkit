# Generates batch wrappers for the powershell commands

$commandDir = Join-Path $PSScriptRoot "..\ps-commands"
$wrapperDir = Join-Path $PSScriptRoot "..\..\build\bat-wrappers"

# Create dir if doesn't exist
[System.IO.Directory]::CreateDirectory($wrapperDir) | Out-Null

# Clear wrappers
Get-ChildItem -Path $wrapperDir -File | Remove-Item

# Function to build the wrapper content
function New-WrapperContent($commandPath) {
return @"
:: Wrapper for "$commandPath"
@echo off
powershell -ExecutionPolicy Bypass -File "$commandPath" %*
"@
}

# Create wrappers
Get-ChildItem -Path $commandDir -Filter *.ps1 | ForEach-Object {
    $commandName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    $commandPath = $_.FullName

    $wrapperContent = New-WrapperContent $commandPath
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
tp
exit
"@
