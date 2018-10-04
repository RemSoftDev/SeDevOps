function Copy-SeVm {
    param (
    [string]$NameOfConfig
    )
    
    $ScriptRoot = $PSScriptRoot
    $pathToConfig = Join-Path -Path $ScriptRoot -ChildPath "Configs\$NameOfConfig.json"
    $obj = [CopyVm[]](Get-Content $pathToConfig | ConvertFrom-Json)
    
}