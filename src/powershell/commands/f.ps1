# Open a new file explorer window at a specified directory.

param (
    [string]$Path = "."
)

Start-Process (Resolve-Path $Path)
