$ErrorActionPreference = "Stop"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted
$ScriptRoot = $PSScriptRoot
Import-Module -Force (Join-Path $ScriptRoot 'List1\List1') 
Import-Module -Force (Join-Path $ScriptRoot 'List2\List2') 
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

$readHostText = "Choose a step number. Default is 0"

function Get-List1 () {

    Show-MenuList 6 "List1"
    $StepNumber = 0
    $StepNumber = Read-Host $readHostText  

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
            Get-SeTask5 ""
            Get-SeTask5 "123"
            Get-SeTask5 
        }
        6 { 
            Get-SeTask6 $true
            Get-SeTask6 $false
            Get-SeTask6
        }
    }
}
function Get-List2 () {

    Show-MenuList 6 "List2"
    $StepNumber = 0
    $StepNumber = Read-Host $readHostText   

    switch ( $StepNumber ) {
        0 { Remove-AzureRmResourceGroup }
        1 {     
            $path = Join-Path -Path $ScriptRoot -ChildPath  "List1"
            Get-SeList2Task1 $path
        }
        2 { 
            $path = Join-Path -Path $ScriptRoot -ChildPath  "List2\devops.bacpac"
            Get-SeList2Task2 $path
        }
        3 { 

        }
        4 { 

        }
        5 { 

        }
        6 { 

        }
    }
}
function Show-Menu () {
    Write-Host "1: List1 tasks" -ForegroundColor Magenta
    Write-Host "2: List2 tasks" -ForegroundColor Magenta
}

function Test () {
    Get-SeList2Task4
}

Show-Menu
$StepNumber = Read-Host $readHostText
if (!$StepNumber) {
    $StepNumber = 0
}

switch ( $StepNumber ) {
    0 { Test }
    1 { Get-List1 }
    2 { Get-List2 }
}