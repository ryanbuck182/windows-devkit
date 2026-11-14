<#
.SYNOPSIS
Rebuild and reinstall the devkit from its clone
#>

$setup = Join-Path $DevkitRoot "setup.bat"
if (Test-Path $setup) {
    & $setup
} else {
    Write-Error "The devkit wasn't installed from a clone. To update it, paste the latest dist/devkit-install.ps1 into PowerShell."
}
