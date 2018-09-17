function Copy-SeFile {
    param (
        [byte]$count,
        [string]$pathToFile
    )
    
    if ([System.IO.File]::Exists($pathToFile)) {
    
        $dir = (Get-Item $pathToFile).Directory
        $baseName = (Get-Item $pathToFile).BaseName
        $baseExtention = (Get-Item $pathToFile).Extension
        
        For ($i = 0; $i -lt $count; $i++) {
            $pathToNewFile = Join-Path -Path $dir -ChildPath "$baseName.$i$baseExtention"
            Copy-Item -Path $pathToFile -Destination $pathToNewFile
        }
    }
}

function Set-SeValueForLine {
    param (
        [byte]$lineNumber,
        [string]$value,
        [string]$pathToFile
    )
    
    $filecontent = Get-Content $pathToFile

    if ($filecontent.Length -gt $lineNumber) {
        $filecontent[$lineNumber] = $value
        	
        Set-Content -Path $pathToFile -Value $filecontent
    }
}

function Set-SeValueForLineorFiles {
    param (
        [byte]$lineNumberStart,
        [string]$valueStart,
        [string]$pathToFile
    )

    $dir = (Get-Item $pathToFile).Directory
    $baseName = (Get-Item $pathToFile).BaseName
    $baseExtention = (Get-Item $pathToFile).Extension
    $count = 0

    Get-ChildItem -Path $dir -Filter "$baseName*$baseExtention" | ForEach-Object {
        $count++
        Set-SeValueForLine $lineNumberStart $valueStart $_.FullName
        $lineNumberStart++
        $valueStart = "$valueStart.$count"
    }
}

function Set-SeTask2 {
    param (
        [string]$pathToFile
    )
    $obj = Get-Content $pathToFile | ConvertFrom-Json
    $obj.glossary.GlossDiv.GlossList.GlossEntry.SortAs = "OMPL"

    $filecontent = $obj | ConvertTo-Json -Depth 32
    Set-Content -Path $pathToFile -Value $filecontent
}

function Get-SeTask3 {
    param (
        [string]$pathToFile
    )
    $count = 0
    $obj = [Task3Unit[]](Get-Content $pathToFile | ConvertFrom-Json)
    $obj | ForEach-Object {
        Write-Host ("Obj number is: {0}" -f $count) -ForegroundColor DarkGreen
        $_.PSObject.Properties | ForEach-Object {
            Write-Host ("Prop name is: {0}" -f $_.Name) -ForegroundColor DarkMagenta
            Write-Host ("Prop value is: {0}" -f $_.Value) -ForegroundColor DarkCyan
        }
        $count++
    }
}

function Get-SeTask4 {
    # Microsoft® SQL Server® Data-Tier Application Framework (June 30 2016)
    $name = "DacFramework_2016_{0}"

    $path = "c:/msi"
    If (!(test-path $path)) {
        New-Item -ItemType Directory -Force -Path $path
    }

    $x86 = "x86"
    $url = "https://download.microsoft.com/download/6/E/4/6E406E38-0A01-4DD1-B85E-6CA7CF79C8F7/EN/{0}/DacFramework.msi"

    $type = $x86
    $source = $url -f $type 
    $destination = Join-Path -Path $path -ChildPath "$($name -f $type).msi"

    if ([System.IO.File]::Exists($destination)) {
        Write-Host "[Output]: File exists with next path: $destination" -ForegroundColor DarkGreen
    }
    else {       
        $client = New-Object System.Net.WebClient
        $client.DownloadFile($source, $destination)
        Write-Host "[Output]: File exists with next path: $destination" -ForegroundColor DarkGreen
        Write-Host "[Output]: File was downloaded from url: $source" -ForegroundColor DarkGreen
    }
}

function Get-SeTask5 {
    param (
        [string]$var
    )
    Write-Host "[Output]: ************* " -ForegroundColor DarkGreen

    if ([string]::IsNullOrEmpty($var))
    {
        Write-Host "[Output]: var is IsNullOrEmpty"
        Get-SeTask5 ([guid]::NewGuid())
    }
    else {
        Write-Host "[Output]: var value is: $var"
    } 
}