$dism = "Dism.exe"
function Start-CleanUp {
    & $dism /online /Cleanup-Image /StartComponentCleanup /ResetBase
}

function Start-CleanMgr {
    Write-Host 'Clearing CleanMgr.exe automation settings.'
    Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' -Name StateFlags0001 -ErrorAction SilentlyContinue | Remove-ItemProperty -Name StateFlags0001 -ErrorAction SilentlyContinue
    
    Write-Host 'Enabling Update Cleanup. This is done automatically in Windows 10 via a scheduled task.'
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -Name StateFlags0001 -Value 2 -PropertyType DWord
    
    Write-Host 'Enabling Temporary Files Cleanup.'
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -Name StateFlags0001 -Value 2 -PropertyType DWord
    
    Write-Host 'Starting CleanMgr.exe...'
    Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -WindowStyle Hidden -Wait
    
    Write-Host 'Waiting for CleanMgr and DismHost processes. Second wait neccesary as CleanMgr.exe spins off separate processes.'
    Get-Process -Name cleanmgr, dismhost -ErrorAction SilentlyContinue | Wait-Process
    
    $UpdateCleanupSuccessful = $false
    if (Test-Path $env:SystemRoot\Logs\CBS\DeepClean.log) {
        $UpdateCleanupSuccessful = Select-String -Path $env:SystemRoot\Logs\CBS\DeepClean.log -Pattern 'Total size of superseded packages:' -Quiet
    }
    
    if ($UpdateCleanupSuccessful) {
        Write-Host 'Rebooting to complete CleanMgr.exe Update Cleanup....'
        SHUTDOWN.EXE /r /f /t 0 /c 'Rebooting to complete CleanMgr.exe Update Cleanup....'
    }    
}

function Start-ShrinkDisk {
    $size = (Get-PartitionSupportedSize -DriveLetter C | Select-Object SizeMin).SizeMin
    Start-ResizeDisk $size
}

function Start-ExtendDisk {
    $size = (Get-PartitionSupportedSize -DriveLetter C | Select-Object SizeMax).SizeMax
    Start-ResizeDisk $size
}
function Start-ResizeDisk {
    param (
        [int]$size
    )  
    Resize-Partition -DriveLetter C -Size $size
}

function Start-OptimizeVhd {
    param (
        [string]$pathToVhd
    )
    
    Optimize-VHD -Path $pathToVhd -Mode Full
}

function Start-ResizeVhd {
    param (
        [string]$pathToVhd
    )

    Resize-VHD -Path $pathToVhd -SizeBytes 127GB
}

function Start-CleanupVMandVHD {
    param (
        [string]$config

    $vmName = $config.NameOfVm

    Get-VMSnapshot  -VMName $vmName | Remove-VMSnapshot
    Set-VM -Name $vmName -AutomaticCheckpointsEnabled $false

    Invoke-Command `
        -VMName $vmName `
        -ScriptBlock ${function:Start-CleanUp} `
        -Credential $mycreds  
    Write-Host ("[Info] VM Start-CleanUp") -ForegroundColor DarkGreen
    
    Invoke-Command `
        -VMName $vmName `
        -ScriptBlock ${function:Start-CleanMgr} `
        -Credential $mycreds  
    Write-Host ("[Info] VM Start-CleanMgr") -ForegroundColor DarkGreen

    Invoke-Command `
        -VMName $vmName `
        -ScriptBlock ${function:Start-ShrinkDisk} `
        -Credential $mycreds  
    Write-Host ("[Info] VM Start-ShrinkDisk") -ForegroundColor DarkGreen

    Stop-VM -Name $vmName -Force

    Start-OptimizeVhd $config.PathToVhd
    Write-Host ("[Info] VM Start-OptimizeVhd") -ForegroundColor DarkGreen
    
    Start-ResizeVhd $config.PathToVhd
    Write-Host ("[Info] VM Start-ResizeVhd") -ForegroundColor DarkGreen
    
    Start-VM -Name $vmName

    Invoke-Command `
        -VMName $vmName `
        -ScriptBlock ${function:Start-ExtendDisk} `
        -Credential $mycreds  
    Write-Host ("[Info] VM Start-ExtendDisk") -ForegroundColor DarkGreen
}