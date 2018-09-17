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

function Set-SeValueForLineorFiles{
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