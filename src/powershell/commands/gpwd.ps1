<#
.SYNOPSIS
Get the path to the working directory

.DESCRIPTION
It will be surrounded in quotes
#>

Write-Output ('"' + (Get-Location).Path + '"')
