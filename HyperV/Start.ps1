Set-ExecutionPolicy Unrestricted -Scope CurrentUser
Set-ExecutionPolicy Unrestricted -Scope Process
$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
Import-Module -Force (Join-Path $ScriptRoot 'CopyVm\CopyVm') 
# Import-Module -Force (Join-Path $ScriptRoot 'TopoVm\TopoVm') 
Import-Module -Force (Join-Path $ScriptRoot 'ClearVm\ClearVm') 

$readHostText = "Choose a step number. Default is 0"
function Show-Menu () {
    Write-Host "1: Copy-SeVm" -ForegroundColor Magenta
}

function Test () {
    Start-ResizeVhd "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\Cleanws2016GUI.vhdx"
}

Show-Menu
$StepNumber = Read-Host $readHostText
if (!$StepNumber) {
    $StepNumber = 0
}

switch ( $StepNumber ) {
    0 { Test }
    1 { Copy-SeVm "CopyVm" }
}