$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
Import-Module -Force (Join-Path $ScriptRoot 'CopyVm\CopyVm') 

$readHostText = "Choose a step number. Default is 0"
function Show-Menu () {
    Write-Host "1: Copy-SeVm" -ForegroundColor Magenta
}

function Test () {
    Copy-SeVm "CopyVm"
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