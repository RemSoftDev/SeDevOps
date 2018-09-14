function New-SE_StaticModule {
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

    New-ModuleManifest -Path $pathToPsd1 -RootModule $psmFileName -Author $Author -CompanyName $CompanyName
}

$pathToModule = Join-Path -Path (Resolve-Path .) -ChildPath "Accenture"
New-SE_StaticModule "List1" $pathToModule