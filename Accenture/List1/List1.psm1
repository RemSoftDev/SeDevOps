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