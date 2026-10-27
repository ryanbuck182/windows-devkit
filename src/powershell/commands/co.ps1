# Open VS code at the current directory or a specified one

param (
    [string]$Path = "."
)

code (Resolve-Path $Path)
