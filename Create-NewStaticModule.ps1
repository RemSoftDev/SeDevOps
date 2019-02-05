function New-SeStaticModule {
    param (
        [string]$ModuleName,
        [string]$ModuleRootPath,
        [string]$Author = "Oleksandr Dubyna, struggleendlessly@hotmail.com",
        [string]$CompanyName = "Accenture"
    )
    
    if ( -Not (Test-Path -Path $ModuleRootPath ) ) {
        New-Item -ItemType directory -Path $ModuleRootPath
    }

    $ModuleFullPath = Join-Path -Path $ModuleRootPath -ChildPath $ModuleName

    if ( -Not (Test-Path -Path $ModuleFullPath ) ) {
        New-Item -ItemType directory -Path $ModuleFullPath
    }

    $psm = "psm1"
    $psd = "psd1"  

    $psmFileName = "{0}.{1}" -f $ModuleName, $psm
    $psdFileName = "{0}.{1}" -f $ModuleName, $psd

    $pathToPsm1 = Join-Path -Path $ModuleFullPath -ChildPath $psmFileName
    $pathToPsd1 = Join-Path -Path $ModuleFullPath -ChildPath $psdFileName

    New-Item -ItemType File -Path $pathToPsm1

    New-ModuleManifest `
        -Path $pathToPsd1 `
        -RootModule $psmFileName `
        -Author $Author `
        -CompanyName $CompanyName `
        -ScriptsToProcess "Classes\$ModuleName.class.ps1"
}

function New-SeCreateSubFolders {
    param (
        [string]$ModuleName,
        [string]$ModuleRootPath
    )
    
    $path = Join-Path -Path $ModuleRootPath -ChildPath $ModuleName
    $pathToClassesFolder = Join-Path -Path $path -ChildPath "Classes"
    $pathToConfigsFolder = Join-Path -Path $path -ChildPath "Configs"
  
    New-Item -ItemType directory -Path $pathToClassesFolder
    New-Item -ItemType directory -Path $pathToConfigsFolder

    $pathToClassesFile = Join-Path -Path $pathToClassesFolder -ChildPath "$ModuleName.class.ps1"
    $pathToConfigsFile = Join-Path -Path $pathToConfigsFolder -ChildPath "$ModuleName.json"

    New-Item -ItemType File -Path $pathToClassesFile 
    New-Item -ItemType File -Path $pathToConfigsFile 
}

function Add-SeStartModule {
    param (
        [string]$pathToStart,
        [string]$ModuleName
    )
    $ScriptRoot = '$ScriptRoot'
    $ImportModule = "Import-Module -Force (Join-Path $ScriptRoot '" + $ModuleName + "')" 
    if (Test-Path $pathToStart) {

        $overlap = Select-String -Path $pathToStart -Pattern $ImportModule -SimpleMatch

        if ($overlap.length -eq 0) {
            $overlapForInsert = Select-String -Path $pathToStart -Pattern  "Import-Module"
            $lintOfLastImportedModule = $overlapForInsert[$overlapForInsert.length - 1].LineNumber
            $fileContent = Get-Content $pathToStart
            $fileContent[$lintOfLastImportedModule] += $ImportModule + "`r`n"
            $fileContent | Set-Content $pathToStart

            Write-Host "Added" -ForegroundColor Green
            Write-Host $ImportModule
        }
    }
}

function Add-SeStartFile {
    param (
        [string]$pathToStart,
        [string]$pathToDefaultStart
    )

    if (-not (Test-Path $pathToStart)) {
        Copy-Item -Path $pathToDefaultStart -Destination $pathToStart
    }
}
function Update-SeStart {
    param (
        [string]$pathToModuleFolder,
        [string]$ModuleName
    )
    $start = "Start.ps1"
    $pathToDefaultStart = Join-Path -Path $PSScriptRoot -ChildPath $start
    $pathToStart = Join-Path -Path $pathToModuleFolder -ChildPath $start

    Add-SeStartFile $pathToStart $pathToDefaultStart
    Add-SeStartModule $pathToStart $ModuleName      
}
function New-Se {
    $pathBase = Resolve-Path .

    $pathsArray = New-Object string[] 10
    $pathsArray[0] = Join-Path -Path $pathBase -ChildPath "Accenture"
    $pathsArray[1] = Join-Path -Path $pathBase -ChildPath "Azure"
    $pathsArray[2] = Join-Path -Path $pathBase -ChildPath "System"
    $pathsArray[3] = Join-Path -Path $pathBase -ChildPath "HyperV"
    $pathsArray[4] = Join-Path -Path $pathBase -ChildPath "sql"
    
    $ModuleRootPath = $pathsArray[4]
    $ModuleName = "Setup"
    
    $pathTest = Join-Path -Path $ModuleRootPath -ChildPath $ModuleName
    if (!(Test-Path -Path $pathTest )) {
        New-SeStaticModule $ModuleName $ModuleRootPath
        New-SeCreateSubFolders $ModuleName $ModuleRootPath
    }

    Update-SeStart $ModuleRootPath $ModuleName
}

New-Se