# Open a new administrator powershell window that properly handles the opening of new tabs.
# This is a workaround for this bug https://github.com/microsoft/terminal/issues/9628
# which prevents the tp command from working correctly in an administrator window.

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
