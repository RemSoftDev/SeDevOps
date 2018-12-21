if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning  -Message "Please run script this with Administrator rights"
    return
}

$pathToVhd = "C:\Users\Public\Documents\Hyper-V\Virtual hard disks\GIT.vhdx"

$readHostText = "0 - set, 1 - remove"
$StepNumber = Read-Host $readHostText
if (!$StepNumber) {
    $StepNumber = 0
}

switch ( $StepNumber ) {
    0 { Mount-VHD -Path $pathToVhd }
    1 { Dismount-VHD -Path $pathToVhd  }
}



