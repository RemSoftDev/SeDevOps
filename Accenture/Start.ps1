$ScriptRoot = $PSScriptRoot
Import-Module -Force (Join-Path $ScriptRoot 'List1\List1') 
Get-Module
function Show-MenuList1 () {
    Write-Host "1: List1 task 1" -ForegroundColor DarkGreen
    Write-Host "2: List1 task 2" -ForegroundColor DarkGreen
    Write-Host "3: List1 task 3" -ForegroundColor DarkGreen
    Write-Host "4: List1 task 4" -ForegroundColor DarkGreen
    Write-Host "5: List1 task 5" -ForegroundColor DarkGreen
}

function Get-List1 () {

    Show-MenuList1
    $StepNumber = 0
    $StepNumber = Read-Host "Choose a step number. Default is 0"   
    if (!$StepNumber) {

    }

    switch ( $StepNumber ) {
        0 {  }
        1 { Copy-SeFile 3 "C:\Users\oleksandr.dubyna\Documents\GIT\SE\SeDevOps\Accenture\List1\xmlFile.xml" }
    }
}
function Show-Menu () {
    Write-Host "1: List1 tasks" -ForegroundColor Magenta
}

function Test () {
    # Copy-SeFile 3 "C:\Users\oleksandr.dubyna\Documents\GIT\SE\SeDevOps\Accenture\List1\xmlFile.xml"
    Set-SeValueForLine 3 "123" "C:\Users\oleksandr.dubyna\Documents\GIT\SE\SeDevOps\Accenture\List1\xmlFile.xml"
}

Show-Menu
$StepNumber = Read-Host "Choose a step number. Default is 0"
if (!$StepNumber) {
    $StepNumber = 0
}

switch ( $StepNumber ) {
    0 { Test }
    1 { Get-List1 }
}