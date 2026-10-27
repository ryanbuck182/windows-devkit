# Get the path to the working directory
# It will be surrounded in quotes

Write-Output ('"' + (Get-Location).Path + '"')
