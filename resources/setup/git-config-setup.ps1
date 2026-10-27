# My preferred configuration options for git.
# The settings and aliases themselves are in src/git/devkit.gitconfig

# Username and email
$configPath = (Join-Path $PSScriptRoot "..\..\config.psd1")
if (Test-Path $configPath) {
    $config = Import-PowerShellDataFile -Path $configPath
    git config --global user.name $config.GitUserName
    git config --global user.email $config.GitUserEmail
} else {
    Write-Output "Unable to set git username and email because config file does not exist!"
    Write-Output "Please follow the instructions in config.psd1.template!"
}

# -------------------------
# ---------Include---------
# -------------------------

$devkitConfig = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\src\git\devkit.gitconfig")) -replace '\\', '/'

$globalConfig = $env:GIT_CONFIG_GLOBAL
if (-not $globalConfig) { $globalConfig = Join-Path $HOME ".gitconfig" }

$includes = @(git config --global --get-all include.path 2>$null)

if ($includes -contains $devkitConfig) {
    Write-Output "Devkit gitconfig is already included"
} elseif ($includes -like "*devkit.gitconfig") {
    # The devkit moved, so update the path in place
    git config --global --replace-all include.path $devkitConfig 'devkit\.gitconfig$'
} else {
    # Older versions of setup wrote everything directly to the global config
    # Remove those values so they don't override the included ones
    $devkitKeys = @(git config --file $devkitConfig --name-only --list) + "alias.aliasconfig"
    foreach ($key in $devkitKeys) {
        git config --global --unset-all $key 2>$null
    }

    # Include at the top so values set in the global config override the devkit ones
    $content = ""
    if (Test-Path $globalConfig) { $content = [System.IO.File]::ReadAllText($globalConfig) }
    $include = "[include]`n`tpath = $devkitConfig`n"
    [System.IO.File]::WriteAllText($globalConfig, $include + $content, (New-Object System.Text.UTF8Encoding $false))
}
