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

    switch ( $StepNumber ) {
        0 {  }
        1 {     
            $path = Join-Path -Path $ScriptRoot -ChildPath  "List1\task1.xml"
            Copy-SeFile 3 $path 
            Set-SeValueForLineorFiles 3 "123" $path 
        }
        2 { 
            $path = Join-Path -Path $ScriptRoot -ChildPath  "List1\task2.json"
            Set-SeTask2 $path
        }
        3 {  }
        4 {  }
        5 {  }
        6 {  }
        7 {  }
    }
}
function Show-Menu () {
    Write-Host "1: List1 tasks" -ForegroundColor Magenta
}

function Test () {
    
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