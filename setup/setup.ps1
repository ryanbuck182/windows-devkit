param (
    [Alias('s', 'skip')][switch]$SkipConfigDialog
)

if (-not $SkipConfigDialog) {
    Write-Host "Please follow the instructions in config.psd1.template"
    Write-Host "Once you have done so, please press enter..."
    Read-Host | Out-Null
}

Write-Host "Setting git config..."
& (Join-Path $PSScriptRoot ".\git-config-setup.ps1")

Write-Host "`nAdding commands to powershell profile..."
& (Join-Path $PSScriptRoot ".\populate-profile.ps1")

Write-Host "`nGenerating batch wrappers..."
& (Join-Path $PSScriptRoot ".\generate-wrappers.ps1")

Write-Host "`nAdding batch wrappers to the PATH environment variable..."
& (Join-Path $PSScriptRoot ".\add-wrappers-to-path.ps1")

Write-Host "`nFinished!`n"
