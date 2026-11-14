# Installs the devkit to ~/.devkit
# This isn't run on its own. build.ps1 puts it in dist/devkit-install.ps1 after defining:
#   $Clone     the clone setup.bat was run from, or nothing when the installer is pasted
#   $files     the files to install, by their path in ~/.devkit
#   $commands  the names of the devkit commands

$ErrorActionPreference = 'Stop'

$installDir = Join-Path $HOME '.devkit'
Write-Host "Installing the devkit to $installDir"

# Commands use $DevkitRoot to find the devkit: the clone it was installed from, or ~/.devkit
if ($Clone) { $DevkitRoot = [System.IO.Path]::GetFullPath($Clone) } else { $DevkitRoot = $installDir }
$files['devkit.ps1'] = "`$DevkitRoot = '$($DevkitRoot.Replace("'", "''"))'`n" + $files['devkit.ps1']

# Each command gets a batch wrapper so it can be run from cmd, unless it has its own batch version
# setlocal keeps DEVKIT_COMMAND from staying set in the cmd window
foreach ($command in $commands) {
    if (-not $files.Contains("bin\$command.bat")) {
        $files["bin\$command.bat"] = @"
:: Wrapper for the $command command
@echo off
setlocal
set "DEVKIT_COMMAND=$command"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\run.ps1" %*
"@
    }
}

# -------------------------
# ----------Files----------
# -------------------------

$binDir = Join-Path $installDir 'bin'
New-Item -ItemType Directory -Force $binDir | Out-Null

# Remove old wrappers so deleted commands don't stick around
Get-ChildItem $binDir -Filter *.bat | Remove-Item

foreach ($path in $files.Keys) {
    # Windows line endings, since cmd can misread batch files without them
    $content = ($files[$path] -replace "`r?`n", "`r`n") + "`r`n"
    [System.IO.File]::WriteAllText((Join-Path $installDir $path), $content)
}

# -------------------------
# -----------Git-----------
# -------------------------

$gitconfig = $env:GIT_CONFIG_GLOBAL
if (-not $gitconfig) { $gitconfig = Join-Path $HOME '.gitconfig' }

$include = '~/.devkit/devkit.gitconfig'
$includes = @(git config --global --get-all include.path)

if ($includes -contains $include) {
    Write-Host 'Devkit gitconfig is already included'
} elseif ($includes -like '*devkit.gitconfig') {
    # Older versions included it from the clone, so point that include here instead
    git config --global --replace-all include.path $include 'devkit\.gitconfig$'
} else {
    # Include at the top so values set in the global config override the devkit ones
    $content = ''
    if (Test-Path $gitconfig) { $content = [System.IO.File]::ReadAllText($gitconfig) }
    [System.IO.File]::WriteAllText($gitconfig, "[include]`n`tpath = $include`n" + $content)
}

# Ask for whichever of name and email isn't set yet and save it to this machine's global config
foreach ($key in 'user.name', 'user.email') {
    if (-not (git config --global --includes $key)) {
        do { $value = Read-Host "Your git $key" } until ($value)
        git config --global $key $value
    }
}

# -------------------------
# ---------Profile---------
# -------------------------

$userProfile = $PROFILE.CurrentUserAllHosts
$block = (
    '# BEGIN DEVKIT',
    'if (Test-Path "$HOME\.devkit\profile.ps1") { . "$HOME\.devkit\profile.ps1" }',
    '# END DEVKIT'
) -join "`r`n"

# Keep the profile's encoding. Windows PowerShell reads profiles without a BOM as ANSI.
$text = ''
$encoding = [System.Text.Encoding]::Default
if (Test-Path $userProfile) {
    $reader = New-Object System.IO.StreamReader $userProfile, $encoding, $true
    $text = $reader.ReadToEnd()
    $encoding = $reader.CurrentEncoding
    $reader.Close()
} else {
    New-Item -ItemType Directory -Force (Split-Path $userProfile) | Out-Null
}

# Replace the devkit block, including the one older versions added
$text = [regex]::Replace($text, '(?s)# BEGIN DEVKIT.*?# END DEVKIT[^\n]*\n?', '').Trim()
if ($text) { $text += "`r`n`r`n" }
$text += $block + "`r`n"
[System.IO.File]::WriteAllText($userProfile, $text, $encoding)

# -------------------------
# -----------PATH----------
# -------------------------

# Edit the registry value directly to keep its type
# Entries like %USERPROFILE%\... stop working if it gets saved as a plain string
$envKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
$path = $envKey.GetValue('Path', '', 'DoNotExpandEnvironmentNames')
$kind = 'ExpandString'
if ($envKey.GetValueNames() -contains 'Path') { $kind = $envKey.GetValueKind('Path') }

# Older versions put the wrappers in build\bat-wrappers in the clone
$entries = @($path -split ';' | Where-Object { $_ -and $_ -notlike '*\build\bat-wrappers' })
if ($entries -notcontains $binDir) { $entries += $binDir }

$newPath = $entries -join ';'
if ($newPath -ne $path) {
    $envKey.SetValue('Path', $newPath, $kind)
    # Changing any user variable this way tells open programs like Explorer to reload the environment
    [Environment]::SetEnvironmentVariable('DEVKIT_UNUSED', $null, 'User')
}
$envKey.Close()

# So cmd commands work in this window too
if (($env:PATH -split ';') -notcontains $binDir) { $env:PATH += ";$binDir" }

# -------------------------
# ----------Done-----------
# -------------------------

# Profiles only load if the execution policy allows scripts
# The process scope is skipped since it only applies to this window
$policy = 'MachinePolicy', 'UserPolicy', 'CurrentUser', 'LocalMachine' |
    ForEach-Object { Get-ExecutionPolicy -Scope $_ } |
    Where-Object { $_ -ne 'Undefined' } |
    Select-Object -First 1
if (-not $policy) { $policy = 'Restricted' }

if ($policy -in 'Restricted', 'AllSigned') {
    Write-Warning "The execution policy is $policy, so devkit commands won't load in PowerShell."
    Write-Warning 'To allow them, run: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser'
}

Write-Host 'Finished! Open a new terminal window to use the devkit.'
