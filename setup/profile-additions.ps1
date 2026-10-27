# The output of this script gets added to the powershell profile on setup

$prompt = Get-Content (Join-Path $PSScriptRoot "..\src\powershell\profile\prompt.ps1") -Raw
$branchComplete = Get-Content (Join-Path $PSScriptRoot "..\src\powershell\profile\git-branch-autocomplete.ps1") -Raw

Write-Output $prompt
Write-Output $branchComplete
