# Show ALL files and directories in the path

param (
    [string]$Path = "."
)

Get-ChildItem -Path $Path -Force
