# Open notepad

param (
    [string]$Path = "."
)

notepad.exe (Resolve-Path $Path)
