$DevkitRoot = Join-Path $PSScriptRoot ".." | Resolve-Path

$DevkitDir = [PSCustomObject]@{
    Root = $DevkitRoot
    Src = "$DevkitRoot\src\"
    PSCommands = "$DevkitRoot\src\powershell\commands\"
    Setup = "$DevkitRoot\setup\"
    Build = "$DevkitRoot\build\"
    BatWrappers = "$DevkitRoot\build\bat-wrappers\"
    ProfileInject = "$DevkitRoot\build\ps-profile\"
}

Export-ModuleMember -Variable $DevkitRoot
Export-ModuleMember -Variable $DevkitDir
