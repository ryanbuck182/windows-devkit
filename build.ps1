# Builds dist/devkit-install.ps1, a single script that installs the devkit
# It can be pasted into PowerShell on any machine, or run from a clone by setup.bat

$ErrorActionPreference = 'Stop'

# Reads a file in the repo and makes sure it's safe to paste into PowerShell
function Get-Source($path) {
    $text = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot $path)) -replace "`r`n", "`n"

    if ($text -match '[^\x00-\x7F]') {
        throw "$path has non-ASCII characters, which Windows PowerShell can misread"
    }
    if ($text -match "(?m)^'@") {
        throw "$path has a line starting with '@, which would end an embedded file in the installer early"
    }

    # Pasted tabs trigger tab completion
    return $text.Replace("`t", '    ').TrimEnd()
}

# Lists the files in a directory in the same order on every machine
function Get-SourceFiles($dir, $filter) {
    $names = [string[]](Get-ChildItem (Join-Path $PSScriptRoot $dir) -Filter $filter -File | ForEach-Object Name)
    [System.Array]::Sort($names, [System.StringComparer]::Ordinal)
    return $names | ForEach-Object { Join-Path $dir $_ }
}

# The files to install, by their path in ~/.devkit
$files = [ordered]@{}

# Every command becomes a function, with the command's script as the body
$commands = @()
$functions = @()
foreach ($file in Get-SourceFiles 'src\powershell\commands' '*.ps1') {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $commands += $name
    $functions += "function $name {`n$(Get-Source $file)`n}"
}
$files['devkit.ps1'] = $functions -join "`n`n"

# The PowerShell profile loads this, which loads the commands
$profileParts = @('. "$PSScriptRoot\devkit.ps1"')
foreach ($file in Get-SourceFiles 'src\powershell\profile' '*.ps1') {
    $profileParts += Get-Source $file
}
$files['profile.ps1'] = $profileParts -join "`n`n"

$files['devkit.gitconfig'] = Get-Source 'src\git\devkit.gitconfig'
$files['run.ps1'] = Get-Source 'src\cmd\run.ps1'

# Some commands have their own batch version, which replaces the generated wrapper
foreach ($file in Get-SourceFiles 'src\cmd' '*.bat') {
    $files["bin\$(Split-Path $file -Leaf)"] = Get-Source $file
}

# The installer embeds each file in a here-string, then runs src/install.ps1
# The & { } around everything means a paste that gets cut off runs nothing
$lines = @(
    '# Installs the devkit to ~/.devkit'
    '# To install, paste this whole file into PowerShell, or run setup.bat in a clone of the repo'
    '# This is built from src/ by build.ps1, so edit those files instead of this one'
    ''
    '& {'
    'param([string]$Clone)'
    ''
    '$files = [ordered]@{}'
    ''
)
foreach ($path in $files.Keys) {
    $lines += "`$files['$path'] = @'", $files[$path], "'@", ''
}
$lines += '$commands = ' + (($commands | ForEach-Object { "'$_'" }) -join ', ')
$lines += ''
$lines += Get-Source 'src\install.ps1'
$lines += '} @args'

$dist = Join-Path $PSScriptRoot 'dist'
New-Item -ItemType Directory -Force $dist | Out-Null
[System.IO.File]::WriteAllText((Join-Path $dist 'devkit-install.ps1'), ($lines -join "`n") + "`n")

Write-Host 'Built dist\devkit-install.ps1'
