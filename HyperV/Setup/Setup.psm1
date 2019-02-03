
function Set-SeVMHost {
    Set-VMHost -MaximumStorageMigrations 2
    Set-VMHost -MacAddressMinimum 00155D020600 -MacAddressMaximum 00155D020699
    Set-VMHost -VirtualHardDiskPath "D:\Hyper-V\VHD" 
    Set-VMHost -VirtualMachinePath "D:\Hyper-V"
}


function Import-SeVMsNewId {
    Get-ChildItem "D:\Hyper-V\Virtual Machines" -Filter *.vmcx | 
        Foreach-Object {
            Import-VM -Path $_.FullName
    }
}

$tempVM = (Compare-VM -Copy -Path "D:\Hyper-V\Virtual Machines\BCBE5EBB-18E1-478D-B0CD-7CFF5B6E80EA.vmcx" -GenerateNewID).VM