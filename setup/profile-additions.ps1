# The output of this script gets added to the powershell profile on setup

$xx = Get-Content (Join-Path $PSScriptRoot "..\src\powershell\profile\xx.ps1") -Raw
$tpx = Get-Content (Join-Path $PSScriptRoot "..\src\powershell\profile\tpx.ps1") -Raw
$prompt = Get-Content (Join-Path $PSScriptRoot "..\src\powershell\profile\prompt.ps1") -Raw
$branchComplete = Get-Content (Join-Path $PSScriptRoot "..\src\powershell\profile\git-branch-autocomplete.ps1") -Raw

Write-Output $xx
Write-Output $tpx
Write-Output $prompt
Write-Output $branchComplete
