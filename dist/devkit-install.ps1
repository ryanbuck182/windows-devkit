# Installs the devkit to ~/.devkit
# To install, paste this whole file into PowerShell, or run setup.bat in a clone of the repo
# This is built from src/ by build.ps1, so edit those files instead of this one

& {
param([string]$Clone)

$files = [ordered]@{}

$files['devkit.ps1'] = @'
function c {
<#
.SYNOPSIS
Alias for cls
#>

Clear-Host
}

function clear {
<#
.SYNOPSIS
Alias for cls
#>

Clear-Host
}

function co {
<#
.SYNOPSIS
Open VS code at the current directory or a specified one
#>

param (
    [string]$Path = "."
)

code (Resolve-Path $Path)
}

function cpwd {
<#
.SYNOPSIS
Copy the path to the working directory to the clipboard

.DESCRIPTION
It will be surrounded in quotes
#>

gpwd | Set-Clipboard
}

function devkit-cd {
<#
.SYNOPSIS
Change the working directory to the devkit directory
#>

Set-Location $DevkitRoot
}

function devkit-cpwd {
<#
.SYNOPSIS
Copy the path to the devkit
#>

Set-Clipboard "`"$DevkitRoot`""
}

function devkit-f {
<#
.SYNOPSIS
Open the devkit in file explorer
#>

Start-Process $DevkitRoot
}

function devkit-rebuild {
<#
.SYNOPSIS
Rebuild and reinstall the devkit from its clone
#>

$setup = Join-Path $DevkitRoot "setup.bat"
if (Test-Path $setup) {
    & $setup
} else {
    Write-Error "The devkit wasn't installed from a clone. To update it, paste the latest dist/devkit-install.ps1 into PowerShell."
}
}

function f {
<#
.SYNOPSIS
Open a new file explorer window at a specified directory.
#>

param (
    [string]$Path = "."
)

Start-Process (Resolve-Path $Path)
}

function g {
<#
.SYNOPSIS
Alias for git
#>

git @args
}

function gpwd {
<#
.SYNOPSIS
Get the path to the working directory

.DESCRIPTION
It will be surrounded in quotes
#>

Write-Output ('"' + (Get-Location).Path + '"')
}

function lsa {
<#
.SYNOPSIS
Show ALL files and directories in the path
#>

param (
    [string]$Path = "."
)

Get-ChildItem -Path $Path -Force
}

function np {
<#
.SYNOPSIS
Open notepad
#>

param (
    [string]$Path = "."
)

notepad.exe (Resolve-Path $Path)
}

function psh {
<#
.SYNOPSIS
Open a new powershell window.
#>

wt --window new nt --profile "Windows Powershell" @args
}

function psha {
<#
.SYNOPSIS
Open a new administrator powershell window that properly handles the opening of new tabs.

.DESCRIPTION
This is a workaround for this bug https://github.com/microsoft/terminal/issues/9628
which prevents the tp command from working correctly in an administrator window.
#>

# Check if script is admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$scriptIsAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($scriptIsAdmin) {
    # Start new ps instance to fix bug
    wt -w new nt
} else {
    # Start new ps instance as admin, then start another instance to fix bug
    Start-Process -Verb RunAs powershell.exe -ArgumentList '-Command', 'wt -w new nt'
}
}

function sp3 {
<#
.SYNOPSIS
Split the current windows terminal tab into three separate powershell instances.
#>

wt --window last sp --profile "Windows Powershell" -V
wt --window last sp --profile "Windows Powershell" -H
}

function to {
<#
.SYNOPSIS
Open a new powershell tab in the current windows terminal window.
#>

wt --window last nt --profile "Windows Powershell" @args
}

function tp {
<#
.SYNOPSIS
Open a new powershell tab in the current windows terminal window.

.DESCRIPTION
Starts in the same directory as where the script is being run from.
#>

wt --window last nt --profile "Windows Powershell" --startingDirectory $PWD.Path @args
}

function tpx {
<#
.SYNOPSIS
Alias for tp + exit
#>

# cmd uses src/cmd/tpx.bat instead

tp
# Give the new tab time to open before closing this one
Start-Sleep -Milliseconds 500
exit
}

function xx {
<#
.SYNOPSIS
Alias for exit
#>

# Didn't wanna do just 'x' to avoid accidents
# cmd uses src/cmd/xx.bat instead

exit
}
'@

$files['profile.ps1'] = @'
. "$PSScriptRoot\devkit.ps1"

$gitBranchNameAutoCompleter = {
    param($wordToComplete, $commandAst, $cursorPos)
    
    $branches = git branch --format='%(refname:short)'
    $matchingBranches = $branches | Where-Object { $_ -like "$wordToComplete*" }
    
    $matchingBranches | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -Native -CommandName git -ScriptBlock $gitBranchNameAutoCompleter
Register-ArgumentCompleter -Native -CommandName g -ScriptBlock $gitBranchNameAutoCompleter

$Global:ShowPromptFull = $false
$Global:ShowPromptGit = $true
$Global:ShowPromptColor = $true

function prompt {
    if ($Global:ShowPromptFull) {
        Write-Host $(Get-Location) -NoNewline
    } else {
        $leaf = Split-Path $(Get-Location) -Leaf
        $parent = Split-Path $(Get-Location) -Parent
        $parentLeaf = Split-Path $parent -Leaf
        Write-Host "$parentLeaf\$leaf" -NoNewline
    }
    
    if ($Global:ShowPromptGit) {
        try {
            $position = git rev-parse --abbrev-ref HEAD 2>$null
            if ($LASTEXITCODE -eq 0) {
                if ($position -eq "HEAD") {
                    $position = (git rev-parse HEAD 2>$null).Substring(0, 7)
                }

                if ($Global:ShowPromptColor) {
                    Write-Host " (" -NoNewline
                    Write-Host "$position" -ForegroundColor Cyan -NoNewline
                    Write-Host ")" -NoNewline
                } else {
                    Write-Host " ($position)" -NoNewline
                }
            }
        } catch {}
    }
    
    return "> "
}

function Toggle-PromptFull {
    $Global:ShowPromptFull = -not $Global:ShowPromptFull
}

function Toggle-PromptGit {
    $Global:ShowPromptGit = -not $Global:ShowPromptGit
}

function Toggle-PromptColor {
    $Global:ShowPromptColor = -not $Global:ShowPromptColor
}
'@

$files['devkit.gitconfig'] = @'
# My preferred configuration options for git.
# The installer includes this file from the global git config.
# Values set in the global config override the ones here.

# -------------------------
# --------Settings---------
# -------------------------

[init]
    defaultBranch = main

[core]
    editor = nano

    # Don't automatically change LF to CRLF when checking out
    autocrlf = input

[pull]
    # Only pull if fastforward is possible
    # Can use plm or plr alias if not
    ff = only

[merge]
    # https://www.ductile.systems/zdiff3/
    conflictstyle = zdiff3

[diff]
    # https://luppeng.wordpress.com/2020/10/10/when-to-use-each-of-the-git-diff-algorithms/
    algorithm = histogram

    # Color moved lines (default is zebra)
    colorMoved = default

[push]
    # Push new local branches to remote automatically
    autoSetupRemote = true

# -------------------------
# ---------Aliases---------
# -------------------------

[alias]
    # -----Simple Aliases------
    s = status
    a = add
    d = diff
    sw = switch
    f = fetch
    pl = pull
    ps = push
    co = checkout

    # -----------Add-----------

    # Add specific changes from the working tree
    ap = add -p

    # Add files that are already tracked
    au = add -u

    # ---------Commit----------
    c = commit
    cm = commit -m
    ca = commit --amend
    cam = commit --amend -m

    # -----------Diff----------
    # Aliases that use the default branch run as shell commands, which start in the repo root
    # They cd back to where git was run from (GIT_PREFIX) so file paths still work
    ds = diff --staged
    dh = diff HEAD
    dm = "!cd \"${GIT_PREFIX:-.}\" && git diff \"$(git default-branch)\""
    dl = diff HEAD~1

    # Only the names and statuses of the files that changed
    df = diff --name-status
    dsf = diff --staged --name-status
    dhf = diff HEAD --name-status
    dmf = "!cd \"${GIT_PREFIX:-.}\" && git diff \"$(git default-branch)\" --name-status"
    dlf = diff HEAD~1 --name-status

    # -----------Log-----------
    l = log --oneline
    l5 = log --oneline -5
    l10 = log --oneline -10
    l15 = log --oneline -15

    lg = log --oneline --graph
    lg5 = log --oneline --graph -5
    lg10 = log --oneline --graph -10
    lg15 = log --oneline --graph -15

    # In HEAD but not the default branch
    lmh = "!cd \"${GIT_PREFIX:-.}\" && git log --oneline \"$(git default-branch)\"..HEAD"

    # In the default branch but not HEAD
    lhm = "!cd \"${GIT_PREFIX:-.}\" && git log --oneline HEAD..\"$(git default-branch)\""

    # ---------Switch----------
    # Create new branch and switch to it
    swc = switch -c
    # Switch to the default branch
    swm = "!git switch \"$(git default-branch)\""

    # ----------Stash----------
    sh = stash
    shs = stash show
    shl = stash list
    shps = stash push
    shop = stash pop
    sha = stash apply

    # ----------Merge----------
    mg = merge
    mgc = merge --continue
    mga = merge --abort

    # ---------Rebase----------
    rb = rebase
    rbo = rebase --onto
    rbi = rebase -i
    rbc = rebase --continue
    rba = rebase --abort

    # ----------Pull-----------
    # Pull with merge/rebase
    plm = -c pull.ff=true pull
    plr = -c pull.ff=true pull --rebase

    # Pull from the default branch and merge
    plomm = "!git -c pull.ff=true pull origin \"$(git default-branch)\""

    # ---------Branch----------

    b = branch
    b-d = branch -D

    # Branch list by last commit
    bl = branch --sort=-committerdate

    # List of fully-merged branches by last commit
    blm = branch --sort=-committerdate --merged

    # Branch list but only the branches that contain a given commit
    blc = branch --sort=-committerdate --contains

    # Print the repo's default branch
    # Uses devkit.defaultBranch if set (git config devkit.defaultBranch <branch>),
    # then the remote's default branch, then master if only master exists, then main
    default-branch = "!f() { \
        git config devkit.defaultBranch && return; \
        b=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null) && echo \"${b#origin/}\" && return; \
        git show-ref -q --verify refs/heads/master && ! git show-ref -q --verify refs/heads/main && echo master && return; \
        echo main; \
    }; f"

    # ---------Restore---------
    ro = restore
    rop = restore --patch

    ros = restore --staged
    rosp = restore --staged --patch

    # ----------Reset----------
    # Purposely made to not be super convenient to type
    r-h = reset --hard
    r-h-h = reset --hard HEAD
    r-h-l = reset --hard HEAD~

    # ---------Remote----------
    rv = remote -v
    rsu = remote set-url

    # ---------Bisect----------
    bs = bisect
    bsst = bisect start
    bsg = bisect good
    bsb = bisect bad
    bso = bisect old
    bsn = bisect new
    bssk = bisect skip
    bs-r = bisect reset

    # ----------Tags-----------

    # Create annotated tag
    t = tag -a

    # Push tags to origin
    pst = push origin --tags

    # ------Miscellaneous------

    # Prune remote tracking branches for remote branches that no longer exist
    fp = fetch --prune

    # Remove all untracked files
    cfd = clean -fd

    # List all aliases
    get-aliases = config --get-regexp ^alias\\.
    ga = get-aliases
'@

$files['run.ps1'] = @'
# Runs a devkit command from cmd
# The batch wrappers set DEVKIT_COMMAND to the name of the command to run

. (Join-Path $PSScriptRoot "devkit.ps1")
& $env:DEVKIT_COMMAND @args
'@

$files['bin\tpx.bat'] = @'
:: Alias for tp + exit
:: exit has to run in cmd itself, so this replaces the generated wrapper
@echo off
call tp
:: Give the new tab time to open before closing this one
timeout /t 1 /nobreak > nul
exit
'@

$files['bin\xx.bat'] = @'
:: Alias for exit
:: exit has to run in cmd itself, so this replaces the generated wrapper
@echo off
exit
'@

$commands = 'c', 'clear', 'co', 'cpwd', 'devkit-cd', 'devkit-cpwd', 'devkit-f', 'devkit-rebuild', 'f', 'g', 'gpwd', 'lsa', 'np', 'psh', 'psha', 'sp3', 'to', 'tp', 'tpx', 'xx'

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
} @args
