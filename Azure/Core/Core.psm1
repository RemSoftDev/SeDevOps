function Get-LoginToAzureRm {
    param (
        [string]$key,
        [string]$value,
        [string]$idTenant,
        [string]$idSubscription
    )

    Connect-AzureRmAccount `
        -ServicePrincipal `
        -Credential (Create-PSCredential $key $value) `
        -TenantId $idTenant `
        -Subscription $idSubscription `
        -EnvironmentName "AzureCloud" 
}

function Create-PSCredential {
    param (
        [string]$key,
        [string]$value
    )
    
    $secPass = ConvertTo-SecureString $value -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential ($key, $secPass)
}

function Set-IfNotExistsAzureRmResourceGroup {
    param (
        [string]$resourceGroupName,
        [string]$resourceGroupLocation
    )

    Get-AzureRmResourceGroup `
        -Name $resourceGroupName `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentResourceGroup

    if ($notPresentResourceGroup) {
        Write-Host "[Output]:AzureRmResourceGroup with name: $resourceGroupName does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureRmResourceGroup with name: $resourceGroupName creating " -ForegroundColor DarkMagenta

        New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
    }
    else {
        Write-Host "[Output]:AzureRmResourceGroup with name: $resourceGroupName exists " -ForegroundColor DarkGreen
    }    
}

function  Remove-SeAzureRmResourceGroup {
    param (
        [string]$resourceGroupName
    )
    Write-Host "[Output]: Remove-AzureRmResourceGroup with name: $resourceGroupName" -ForegroundColor DarkGreen
    Remove-AzureRmResourceGroup -ResourceGroupName $resourceGroupName -Force 
}

function Set-IfExistsAzureRmSqlDatabaseExport {
    param (
        [string]$servername,
        [string]$databasename,
        [System.Object]$storageKey,
        [System.Object]$bacpacUri,
        [string]$adminlogin,
        [System.Object]$passwordSecure
    )

    Get-AzureRmSqlDatabase `
        -ResourceGroupName $resourceGroupName `
        -ServerName $servername `
        -DatabaseName $databasename `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentAzureRmSqlDatabaseImport

    if (-not $notPresentAzureRmSqlDatabaseImport) {
        Write-Host "[Output]:IfExistsAzureRmSqlDatabaseExport with name: $databasename exists" -ForegroundColor DarkGreen
        Write-Host "[Output]:IfExistsAzureRmSqlDatabaseExport with name: $databasename exporting" -ForegroundColor DarkMagenta

        $request = New-AzureRmSqlDatabaseExport `
            -ResourceGroupName $resourceGroupName `
            -ServerName $servername `
            -DatabaseName $databasename `
            -StorageKeyType "StorageAccessKey" `
            -StorageKey $storageKey `
            -StorageUri $bacpacUri `
            -AdministratorLogin "$adminlogin" `
            -AdministratorLoginPassword $passwordSecure

        Get-Status "export" $request.OperationStatusLink
    }
    else {
        Write-Host "[Output]:IfExistsAzureRmSqlDatabaseExport with name: $databasename does not exists. Bacpac can not be exported" -ForegroundColor DarkRed
    }
}

# https://github.com/Azure/azure-resource-manager-schemas/blob/d622e3b9447ef112a927c567e7a282c51665114d/schemas/2014-04-01-preview/Microsoft.Sql.json#L332
# "maxSizeBytes": {
#     "oneOf": [
#       {
#         "$ref": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#/definitions/expression"
#       },
#       {
#         "enum": [
#           "104857600",
#           "524288000",
#           "1073741824",
#           "2147483648",
#           "5368709120",
#           "10737418240",
#           "21474836480",
#           "32212254720",
#           "42949672960",
#           "53687091200",
#           "107374182400",
#           "161061273600",
#           "214748364800",
#           "268435456000",
#           "322122547200",
#           "429496729600",
#           "536870912000"
#         ]
#       }
#     ]
#     }
function Set-IfNotExistsAzureRmSqlDatabaseImport {
    param (
        [string]$resourceGroupName,
        [string]$servername,
        [string]$databasename,
        [System.Object]$storageKey,
        [System.Object]$bacpacUri,
        [string]$adminlogin,
        [System.Object]$passwordSecure        
    )

    Get-AzureRmSqlDatabase `
        -ResourceGroupName $resourceGroupName `
        -ServerName $servername `
        -DatabaseName $databasename `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentAzureRmSqlDatabaseImport

    if ($notPresentAzureRmSqlDatabaseImport) {
        Write-Host "[Output]:AzureRmSqlDatabaseImport with name: $databasename does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureRmSqlDatabaseImport with name: $databasename creating " -ForegroundColor DarkMagenta

        $request = New-AzureRmSqlDatabaseImport `
            -ResourceGroupName $resourceGroupName `
            -ServerName $servername `
            -DatabaseName $databasename `
            -DatabaseMaxSizeBytes "21474836480" `
            -StorageKeyType "StorageAccessKey" `
            -StorageKey $storageKey `
            -StorageUri $bacpacUri `
            -Edition "Standard" `
            -ServiceObjectiveName "S4" `
            -AdministratorLogin "$adminlogin" `
            -AdministratorLoginPassword $passwordSecure

        Get-Status "import" $request.OperationStatusLink

        # Scale down to S0 after import is complete
        Write-Host "[Output]:AzureRmSqlDatabaseImport. Scale down to S0 after import is complete.." -ForegroundColor DarkGreen
        Set-AzureRmSqlDatabase `
            -ResourceGroupName $resourceGroupName `
            -ServerName $servername `
            -DatabaseName $databasename  `
            -Edition "Standard" `
            -RequestedServiceObjectiveName "S0"
    }
    else {
        Write-Host "[Output]:AzureRmSqlDatabaseImport with name: $databasename exists. Bacpac can not be imported" -ForegroundColor DarkRed
    }
}

function Set-IfNotExistsAzureRmSqlServerFirewallRule {
    param (
        [string]$servername,
        [string]$firewallRuleName,
        [string]$startip,
        [string]$endip,
        [string]$resourceGroupName
    )

    Get-AzureRmSqlServerFirewallRule `
        -ResourceGroupName $resourceGroupName `
        -ServerName $servername `
        -FirewallRuleName $firewallRuleName `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentAzureRmSqlServerFirewallRule

    if ($notPresentAzureRmSqlServerFirewallRule) {
        Write-Host "[Output]:AzureRmSqlServerFirewallRule with name: $firewallRuleName does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureRmSqlServerFirewallRule with name: $firewallRuleName creating " -ForegroundColor DarkMagenta

        New-AzureRmSqlServerFirewallRule `
            -ResourceGroupName $resourceGroupName `
            -ServerName $servername `
            -FirewallRuleName $firewallRuleName `
            -StartIpAddress $startip `
            -EndIpAddress $endip
    }
    else {
        Write-Host "[Output]:AzureRmSqlServerFirewallRule with name: $firewallRuleName exists " -ForegroundColor DarkGreen
    }
}
function Set-IfNotExistsAzureRmSqlDatabase {
    param (
        [string]$servername,
        [string]$databasename,
        [string]$resourceGroupName
    )

    Get-AzureRmSqlDatabase `
        -ResourceGroupName $resourceGroupName `
        -ServerName $servername `
        -DatabaseName $databasename `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentAzureRmSqlServerFirewallRule

    if ($notPresentAzureRmSqlServerFirewallRule) {
        Write-Host "[Output]:AzureRmSqlDatabase with name: $databasename does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureRmSqlDatabase with name: $databasename creating " -ForegroundColor DarkMagenta

        New-AzureRmSqlDatabase `
            -ResourceGroupName $resourceGroupName `
            -ServerName $servername `
            -DatabaseName $databasename `
            -RequestedServiceObjectiveName "S0" `
            -SampleName "AdventureWorksLT"
    }
    else {
        Write-Host "[Output]:AzureRmSqlDatabase with name: $databasename exists " -ForegroundColor DarkGreen
    }
}

function Set-IfNotExistsAzureRmSqlServer {
    param (
        [string]$servername,
        [System.Object]$sqlAdministratorCredentials,
        [string]$resourceGroupName,
        [string]$resourceGroupLocation
    )
    
    Get-AzureRmSqlServer `
        -ResourceGroupName $resourceGroupName `
        -ServerName $servername `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentAzureRmSqlServer

    if ($notPresentAzureRmSqlServer) {
        Write-Host "[Output]:AzureRmSqlServer with name: $servername does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureRmSqlServer with name: $servername creating " -ForegroundColor DarkMagenta

        New-AzureRmSqlServer `
            -ResourceGroupName $resourceGroupName `
            -ServerName $servername `
            -Location $resourceGroupLocation `
            -SqlAdministratorCredentials $sqlAdministratorCredentials
    }
    else {
        Write-Host "[Output]:AzureRmSqlServer with name: $servername exists " -ForegroundColor DarkGreen
    }
}

function Get-AllAzureRmSqlDatabase {
    param (
        [string]$servername,
        [string]$resourceGroupName
    )
    
    Write-Host "[Output]:[Start] AzureRmSqlServer with name: $servername contains next databases: " -ForegroundColor DarkGreen
    Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $servername 
    Write-Host "[Output]:[End] AzureRmSqlServer" -ForegroundColor DarkGreen
}

function Get-Status {
    param (
        [string]$text,
        [System.Object]$operationStatusLink
    )
    
    Write-Host "[Output]:Check $text status and wait for the $text to complete.." -ForegroundColor DarkGreen
    $importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $operationStatusLink
    [Console]::Write("$($text)ing")
    while ($importStatus.Status -eq "InProgress") {
        $importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $operationStatusLink
        [Console]::Write(".")
        Start-Sleep -s 10
    }
    [Console]::WriteLine("")
    $importStatus
}
