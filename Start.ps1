Set-ExecutionPolicy Unrestricted -Scope Process
Set-ExecutionPolicy Unrestricted -Scope LocalMachine
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
###Import-Module###

$readHostText = "Choose a step number. Default is 0"
function Show-Menu () {
    Write-Host "1: SetupAfterInstall" -ForegroundColor Magenta
}

function Test () {

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