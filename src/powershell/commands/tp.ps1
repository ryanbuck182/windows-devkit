<#
.SYNOPSIS
Open a new powershell tab in the current windows terminal window.

.DESCRIPTION
Starts in the same directory as where the script is being run from.
#>

wt --window last nt --profile "Windows Powershell" --startingDirectory $PWD.Path @args
