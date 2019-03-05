function Enable-SeSqlAuth {
    Choose-AvailableSqlInstances   
    $number = Read-Host "Shoose a number, please (default is 0)"
    Update-AvailableSqlInstances $number
}

function Choose-AvailableSqlInstances {
    Write-Host "Installed SQL instances are:"

    $available = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
    $count = 1

    Write-Host "[0] - Update all available instances" -ForegroundColor DarkCyan

    $available | ForEach-Object {
        Write-Host "[$count] - $_" -ForegroundColor Green
        $count++
    }
}

function Update-AvailableSqlInstances {
    param (
        [int]$number = 0
    )

    $available = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
    $count = 1

    $available | ForEach-Object {
        if ($number -eq 0 -or $number -eq $count) {
            Update-AvailableSqlInstance $_
        }
        $count++
    }
}

function Update-AvailableSqlInstance{
    param (
        [string]$instanceName
    )

    CD SQLSERVER:\SQL\$env:computername\$instanceName
    $SqlCredential  = New-SqlCredential -Name "sa" -Identity "sa" -Secret (ConvertTo-SecureString "1qaz!QAZ" -AsPlainText -Force)
    Set-SqlAuthenticationMode -Mode Mixed -SqlCredential $sqlCredential -ForceServiceRestart
}