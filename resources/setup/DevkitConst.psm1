$DevkitRoot = Join-Path $PSScriptRoot "..\.." | Resolve-Path

$DevkitDir = [PSCustomObject]@{
    Root = $DevkitRoot
    Resources = "$DevkitRoot\resources\"
    PSCommands = "$DevkitRoot\src\powershell\commands\"
    Setup = "$DevkitRoot\resources\setup\"
    Build = "$DevkitRoot\build\"
    BatWrappers = "$DevkitRoot\build\bat-wrappers\"
    ProfileInject = "$DevkitRoot\build\ps-profile\"
}

Export-ModuleMember -Variable $DevkitRoot
Export-ModuleMember -Variable $DevkitDir
