Set-ExecutionPolicy Unrestricted -Scope Process
Set-ExecutionPolicy Unrestricted -Scope LocalMachine
Set-ExecutionPolicy Unrestricted -Scope CurrentUser

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
###Import-Module###
Import-Module SqlServer 
Import-Module -Force (Join-Path $ScriptRoot 'Setup')

$readHostText = "Choose a step number. Default is 0"
function Show-Menu () {
    Write-Host "1: SetupAfterInstall" -ForegroundColor Magenta
}

function Test () {
    Enable-SeSqlAuth
}

Show-Menu
$StepNumber = Read-Host $readHostText
if (!$StepNumber) {
    $StepNumber = 0
}

switch ( $StepNumber ) {
    0 { Test }
    1 {      }
}