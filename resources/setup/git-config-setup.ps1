# My preferred configuration options for git.

# -------------------------
# --------Settings---------
# -------------------------

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

git config --global init.defaultBranch main
git config --global core.editor nano

# Only pull if fastforward is possible
# Can use plm or plr alias if not
git config --global pull.ff only

# https://www.ductile.systems/zdiff3/
git config --global merge.conflictstyle zdiff3

# https://luppeng.wordpress.com/2020/10/10/when-to-use-each-of-the-git-diff-algorithms/
git config --global diff.algorithm histogram

# Color moved lines (default is zebra)
git config --global diff.colorMoved "default"

# Push new local branches to remote automatically
git config --global push.autoSetupRemote true

# Don't automatically change LF to CRLF
git config --global core.autocrlf false

# -------------------------
# ---------Aliases---------
# -------------------------

git config --global --replace-all alias.aliasconfig "config --global --replace-all"

# -----Simple Aliases------
git aliasconfig alias.s "status"
git aliasconfig alias.a "add"
git aliasconfig alias.d "diff"
git aliasconfig alias.sw "switch"
git aliasconfig alias.f "fetch"
git aliasconfig alias.pl "pull"
git aliasconfig alias.ps "push"
git aliasconfig alias.co "checkout"

# -----------Add-----------

# Add specific changes from the working tree
git aliasconfig alias.ap "add -p"

# Add files that are already tracked
git aliasconfig alias.au "add -u"

# ---------Commit----------
git aliasconfig alias.c "commit"
git aliasconfig alias.cm "commit -m"
git aliasconfig alias.ca "commit --amend"
git aliasconfig alias.cam "commit --amend -m"

# -----------Diff----------
git aliasconfig alias.ds "diff --staged"
git aliasconfig alias.dh "diff HEAD"
git aliasconfig alias.dm "diff main"
git aliasconfig alias.dl "diff HEAD~1"

# Only the names and statuses of the files that changed
git aliasconfig alias.df "diff --name-status"
git aliasconfig alias.dsf "diff --staged --name-status"
git aliasconfig alias.dhf "diff HEAD --name-status"
git aliasconfig alias.dmf "diff main --name-status"
git aliasconfig alias.dlf "diff HEAD~1 --name-status"

# -----------Log-----------
git aliasconfig alias.l "log --oneline"
git aliasconfig alias.l5 "log --oneline -5"
git aliasconfig alias.l10 "log --oneline -10"
git aliasconfig alias.l15 "log --oneline -15"

git aliasconfig alias.lg "log --oneline --graph"
git aliasconfig alias.lg5 "log --oneline --graph -5"
git aliasconfig alias.lg10 "log --oneline --graph -10"
git aliasconfig alias.lg15 "log --oneline --graph -15"

# In HEAD but not main
git aliasconfig alias.lmh "log --oneline main..HEAD"

# In main but not HEAD
git aliasconfig alias.lhm "log --oneline HEAD..main"

# ---------Switch----------
# Create new branch and switch to it
git aliasconfig alias.swc "switch -c"
git aliasconfig alias.swm "switch main"

# ----------Stash----------
git aliasconfig alias.sh "stash"
git aliasconfig alias.shs "stash show"
git aliasconfig alias.shl "stash list"
git aliasconfig alias.shps "stash push"
git aliasconfig alias.shop "stash pop"
git aliasconfig alias.sha "stash apply"

# ----------Merge----------
git aliasconfig alias.mg "merge"
git aliasconfig alias.mgc "merge --continue"
git aliasconfig alias.mga "merge --abort"

# ---------Rebase----------
git aliasconfig alias.rb "rebase"
git aliasconfig alias.rbo "rebase --onto"
git aliasconfig alias.rbi "rebase -i"
git aliasconfig alias.rbc "rebase --continue"
git aliasconfig alias.rba "rebase --abort"

# ----------Pull-----------
# Pull with merge/rebase
git aliasconfig alias.plm "-c pull.ff=true pull"
git aliasconfig alias.plr "-c pull.ff=true pull --rebase"

# Pull from main and merge
git aliasconfig alias.plomm "-c pull.ff=true pull origin main"

# ---------Branch----------

git aliasconfig alias.b "branch"
git aliasconfig alias.b-d "branch -D"

# Branch list by last commit
git aliasconfig alias.bl "branch --sort=-committerdate"

# List of fully-merged branches by last commit
git aliasconfig alias.blm "branch --sort=-committerdate --merged"

# Branch list but only the branches that contain a given commit
git aliasconfig alias.blc "branch --sort=-committerdate --contains"

# ---------Restore---------
git aliasconfig alias.ro "restore"
git aliasconfig alias.rop "restore --patch"

git aliasconfig alias.ros "restore --staged"
git aliasconfig alias.rosp "restore --staged --patch"

# ----------Reset----------
# Purposely made to not be super convenient to type
git aliasconfig alias.r-h "reset --hard"
git aliasconfig alias.r-h-h "reset --hard HEAD"
git aliasconfig alias.r-h-l "reset --hard HEAD~"

# ---------Remote----------
git aliasconfig alias.rv "remote -v"
git aliasconfig alias.rsu "remote set-url"

# ---------Bisect----------
git aliasconfig alias.bs "bisect"
git aliasconfig alias.bsst "bisect start"
git aliasconfig alias.bsg "bisect good"
git aliasconfig alias.bsb "bisect bad"
git aliasconfig alias.bso "bisect old"
git aliasconfig alias.bsn "bisect new"
git aliasconfig alias.bssk "bisect skip"
git aliasconfig alias.bs-r "bisect reset"

# ----------Tags-----------

# Create annotated tag
git aliasconfig alias.t "tag -a"

# Push tags to origin
git aliasconfig alias.pst "push origin --tags"

# ------Miscellaneous------

# Prune remote tracking branches for remote branches that no longer exist
git aliasconfig alias.fp "fetch --prune"

# Remove all untracked files
git aliasconfig alias.cfd "clean -fd"

# List all aliases
git aliasconfig alias.get-aliases "config --get-regexp ^alias\."
git aliasconfig alias.ga "get-aliases"
