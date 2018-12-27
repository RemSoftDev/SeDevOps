if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning  -Message "Please run script this with Administrator rights"
    return
}

$ErrorActionPreference = "Stop"
$pathToVhd = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\GIT.vhdx"
$VMName = "vs"

$secpasswd = ConvertTo-SecureString "1qaz!QAZ" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("administrator", $secpasswd)

function Switch-VHD {
    $atachedToVm = $false;
    Get-VMHardDiskDrive -VMName $VMName | Foreach-Object {
        if ($_.Path -match "GIT") {
            $atachedToVm = $true
        }
    }

    $vhdInfo = Get-VHD -Path $pathToVhd
    $atachedToHost = $vhdInfo.Attached -and ($vhdInfo.DiskNumber -eq 1)

    Write-Host "atachedToVm:$($atachedToVm)" -ForegroundColor Blue
    Write-Host "atachedToHost:$($atachedToHost)" -ForegroundColor Blue

    if ($atachedToVm -and !$atachedToHost) {
        DeAttach-FromVm
        Attach-ToHost
        return
    }

    if (!$atachedToVm -and $atachedToHost) {
        DeAttach-FromHost
        Attach-ToVM
        return
    }

    if (!$atachedToVm -and !$atachedToHost) {
        Attach-ToHost
        return
    }
}

function Attach-ToVM {
    Write-Host "Attach-ToVM" -ForegroundColor Green

    Add-VMHardDiskDrive `
        -VMName $VMName `
        -Path $pathToVhd `
        -ControllerType SCSI `
        -ControllerNumber 0 `
        -ControllerLocation 2

    Invoke-Command `
        -VMName $VMName `
        -Credential $mycreds `
        -ScriptBlock {
        Set-Disk -Number 1 -IsReadOnly $False
    }    
}

function Attach-ToHost {
    Write-Host "Attach-ToHost" -ForegroundColor Green

    Mount-VHD -Path $pathToVhd 
}

function DeAttach-FromHost {
    Write-Host "DeAttach-FromHost" -ForegroundColor Green
    Dismount-VHD -Path $pathToVhd
}

function DeAttach-FromVm {
    Write-Host "DeAttach-FromVm" -ForegroundColor Green

    Remove-VMHardDiskDrive `
        -VMName $VMName `
        -ControllerType SCSI `
        -ControllerNumber 0 `
        -ControllerLocation 2
}

Switch-VHD