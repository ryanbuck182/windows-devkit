# Runs a devkit command from cmd
# The batch wrappers set DEVKIT_COMMAND to the name of the command to run

. (Join-Path $PSScriptRoot "..\..\build\ps-profile\inject.ps1")
& $env:DEVKIT_COMMAND @args
