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
