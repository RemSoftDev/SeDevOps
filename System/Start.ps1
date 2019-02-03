Set-ExecutionPolicy Unrestricted -Scope CurrentUser
Set-ExecutionPolicy Unrestricted -Scope Process
$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
Import-Module -Force (Join-Path $ScriptRoot 'SetupAfterInstall') 

$readHostText = "Choose a step number. Default is 0"
function Show-Menu () {
    Write-Host "1: SetupAfterInstall" -ForegroundColor Magenta
}

function Test () {
    Start-ResizeVhd "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\Cleanws2016GUI.vhdx"
    Start-CleanupVMandVHD 
}

Show-Menu
$StepNumber = Read-Host $readHostText
if (!$StepNumber) {
    $StepNumber = 0
}

switch ( $StepNumber ) {
    0 { Test }
    1 { # The order results in a left to right ordering
        $PinnedItems = @(
            'C:\Program Files\Microsoft VS Code\Code.exe'
        )
        
        # Removing each item and adding it again results in an idempotent ordering
        # of the items. If order doesn't matter, there is no need to uninstall the
        # item first.
        foreach($Item in $PinnedItems) {
           Uninstall-TaskBarPinnedItem -Item $Item
           Install-TaskBarPinnedItem   -Item $Item
        }
     }
}