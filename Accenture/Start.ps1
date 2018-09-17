$ScriptRoot = $PSScriptRoot
Import-Module -Force (Join-Path $ScriptRoot 'List1\List1') 
Get-Module
function Show-MenuList () {
    param (
        [byte]$count,
        [string]$listName
    )

    for ($i = 1; $i -le $count; $i++) {
        Write-Host "$i - $listName task $i" -ForegroundColor DarkGreen
    }
}

function Get-List1 () {

    Show-MenuList 10 "List1"
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
        3 { 
            $path = Join-Path -Path $ScriptRoot -ChildPath  "List1\task3.json"
            Get-SeTask3 $path
        }
        4 { 
            Get-SeTask4
        }
        5 { 

        }
        6 {  }
        7 {  }
    }
}
function Show-Menu () {
    Write-Host "1: List1 tasks" -ForegroundColor Magenta
}

function Test () {
    $path = Join-Path -Path $ScriptRoot -ChildPath  "List1\task3.json"
    Get-SeTask3 $path
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