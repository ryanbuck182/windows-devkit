# Copy the path to the working directory to the clipboard
# It will be surrounded in quotes

& (Join-Path $PSScriptRoot ".\gpwd.ps1") | Set-Clipboard
