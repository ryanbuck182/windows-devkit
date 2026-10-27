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
