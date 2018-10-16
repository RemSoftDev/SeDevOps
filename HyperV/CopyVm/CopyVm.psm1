function Copy-SeVm {
    param (
        [string]$NameOfConfig
    )
    $ScriptRoot = $PSScriptRoot
    $pathToConfig = Join-Path -Path $ScriptRoot -ChildPath "Configs\$NameOfConfig.json"
    $config = [CopyVm](Get-Content $pathToConfig | ConvertFrom-Json)
    Write-Host ("Config file have been read succesfully with path: {0}" -f $pathToConfig) -ForegroundColor DarkGreen
    
    Copy-SeVhd $config

    New-VM `
        -Name $config.NameOfVm `
        -MemoryStartupBytes 1073741824 `
        -BootDevice "VHD" `
        -VHDPath $config.PathToVhdNew `
        -Path $config.PathToVhdFolder `
        -Generation 2 `
        -Switch $config.NameOfVsExternal -Verbose

    Set-VMProcessor $config.NameOfVm -Count $config.CountOfCores
    Set-SeVsInternal $config
    Set-VM -Name $config.NameOfVm -AutomaticCheckpointsEnabled $config.AutomaticCheckpointsEnabled
    
    if ($config.AutoStart -eq $true) {
        Start-VM -Name $config.NameOfVm
        Write-Host ("[Info] VM started with name: {0}" -f $config.NameOfVm) -ForegroundColor DarkGreen

        do {Start-Sleep -milliseconds 100} 
        until ((Get-VMIntegrationService $config.NameOfVm | Where-Object {
                    $_.name -eq "Heartbeat"
                }).PrimaryStatusDescription -eq "OK")
    
        Set-SeOther $config
    }
}

function Set-SeNaNames {
    Get-NetAdapter | ForEach-Object {
        $oldName = $_.Name 

        if ($_.LinkSpeed -match "Gbps") {
            $newName = "Internal {0}" -f $oldName
            $_ | Rename-NetAdapter -NewName $newName
        }

        if ($_.LinkSpeed -match "Mbps") {
            $newName = "External {0}" -f $oldName
            $_ | Rename-NetAdapter -NewName $newName
        }
    }   
}

function Enable-NumLock {
    Set-ItemProperty -Path 'Registry::HKU\.DEFAULT\Control Panel\Keyboard' -Name "InitialKeyboardIndicators" -Value "2"
}

function Set-SeOther {
    param (
        [CopyVm]$config
    )

    $secpasswd = ConvertTo-SecureString $config.PcUserPassword -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential ($config.PcUserLogin, $secpasswd)

    Invoke-Command `
        -VMName $config.NameOfVm `
        -ScriptBlock { param($PcTimeZone) Set-TimeZone -Name $PcTimeZone } `
        -ArgumentList $config.PcTimeZone `
        -Credential $mycreds      
    Write-Host ("[Info] VM TimeZone was setted to: {0}" -f $config.PcTimeZone) -ForegroundColor DarkGreen

    Invoke-Command `
        -VMName $config.NameOfVm `
        -ScriptBlock ${function:Set-FileExtensions} `
        -Credential $mycreds
    Write-Host ("[Info] VM FileExtensions was setted to: show") -ForegroundColor DarkGreen

    Invoke-Command `
        -VMName $config.NameOfVm `
        -ScriptBlock ${function:Remove-WindowsAutoUpdates} `
        -Credential $mycreds  
    Write-Host ("[Info] VM WindowsAutoUpdates was setted to: disabled") -ForegroundColor DarkGreen

    Invoke-Command `
        -VMName $config.NameOfVm `
        -ScriptBlock ${function:Set-SeNaNames} `
        -Credential $mycreds  
    Write-Host ("[Info] VM network adapters normal names") -ForegroundColor DarkGreen
    
    Invoke-Command `
        -VMName $config.NameOfVm `
        -ScriptBlock ${function:Enable-NumLock} `
        -Credential $mycreds  
    Write-Host ("[Info] VM Enable NumLock") -ForegroundColor DarkGreen
}

function Remove-WindowsAutoUpdates {
    Stop-Service wuauserv
    Set-Service wuauserv -StartupType disabled
}
function Set-WindowsAutoUpdates {
    Stop-Service wuauserv
    Set-Service wuauserv -StartupType manual
}
function Set-FileExtensions {
    Push-Location
    Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    Set-ItemProperty . HideFileExt "0"
    Pop-Location
}

function Set-SeVsInternal {
    param (
        [CopyVm]$config
    )
    
    if ($config.NameOfVsInternal) {
        Set-SeNewVirtualSwitchIfNotExsists $config.NameOfVsInternal Internal
        Add-VMNetworkAdapter -VMName $config.NameOfVm -Name $config.NameOfVsInternal -SwitchName $config.NameOfVsInternal
        Write-Host ("[Info] Network adapter was succesfylly added with name: {0}" -f $config.NameOfVsInternal) -ForegroundColor DarkGreen
    }
}

function Set-SeNewVirtualSwitchIfNotExsists {
    param (
        [string]$name,
        [string]$type
    )
    
    $is = Get-NetAdapter | Where-Object {
        if ($_.Name -match $name) {
            return $_
        }    
    }

    if ($is) {
        Write-Host ("[Info] Virtual Switch already exsists with name: {0}" -f $is.Name) -ForegroundColor DarkMagenta
    }
    else {
        New-VMSwitch -name $name -SwitchType $type
        Write-Host ("[Info] Virtual Switch succesfully created with name: {0}" -f $name) -ForegroundColor DarkGreen
    }
}

function Copy-SeVhd {
    param (
        [CopyVm]$config
    )
    
    $nameOfNewVhd = "{0}.vhdx" -f $config.NameOfVm
    $pathToNewVhd = "{0}\{1}" -f $config.PathToVhdFolder, $nameOfNewVhd
    
    if (Test-Path -Path $config.PathToVhdInitial ) {
        Write-Host ("[Start] Copying the initial vhd file: {0}" -f $config.PathToVhdInitial) -ForegroundColor DarkGreen

        if (Test-Path -Path $pathToNewVhd ) {
            Write-Error ("[Error] New vhd file already exsists with path: {0}" -f $pathToNewVhd)
        }

        Copy-Item $config.PathToVhdInitial -Destination $pathToNewVhd
        Write-Host ("[End] Copied to path: {0}" -f $pathToNewVhd) -ForegroundColor DarkGreen
        $config.PathToVhdNew = $pathToNewVhd
    }
    else {
        Write-Error ("[Error] Initial vhd file was not found with path: {0}" -f $config.PathToVhdInitial)
    }
}


