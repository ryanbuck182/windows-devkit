$batWrapperDir = Resolve-Path(Join-Path $PSScriptRoot "..\build\bat-wrappers")
$currentPATH = [Environment]::GetEnvironmentVariable("PATH", "User")

if ($currentPATH.Split(';') -notcontains $batWrapperDir) {
    $newPATH = "$currentPATH;$batWrapperDir"
    [Environment]::SetEnvironmentVariable("PATH", $newPATH, "User")
}
