$resourceGroup = "DevOpsGroup"
$location = "westeurope" 
$storageAccountName = "devopsstorageaccount123"
$containerName = "quickstartblobs"
function Set-IfNotExistsAzureRmResourceGroup {
    param (
        [string]$resourceGroup,
        [string]$location
    )

    Get-AzureRmResourceGroup `
        -Name $resourceGroup `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentResourceGroup

    if ($notPresentResourceGroup) {
        Write-Host "[Output]:AzureRmResourceGroup with name: $resourceGroup does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureRmResourceGroup with name: $resourceGroup creating " -ForegroundColor DarkMagenta

        New-AzureRmResourceGroup -Name $resourceGroup -Location $location
    }
    else {
        Write-Host "[Output]:AzureRmResourceGroup with name: $resourceGroup exists " -ForegroundColor DarkGreen
    }    
}
function Set-IfNotExistsAzureRmStorageAccount {
    param (
        [string]$resourceGroup,
        [string]$location,
        [string]$storageAccountName
    )

    $storageAccount = Get-AzureRmStorageAccount `
        -ResourceGroupName $resourceGroup `
        -Name $storageAccountName `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentStorageAccount

    if ($notPresentStorageAccount) {  
        Write-Host "[Output]:AzureRmStorageAccount with name: $storageAccountName does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureRmStorageAccount with name: $storageAccountName creating " -ForegroundColor DarkMagenta

        $storageAccount = 
        New-AzureRmStorageAccount `
            -ResourceGroupName $resourceGroup `
            -Name $storageAccountName `
            -Location $location `
            -SkuName Standard_LRS `
            -Kind Storage
    }  
    else {
        Write-Host "[Output]:AzureRmStorageAccount with name: $storageAccountName exists " -ForegroundColor DarkGreen
    }

    return $storageAccount
}
function Set-IfNotExistsAzureStorageContainer {
    param (
        [string]$containerName,
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.IStorageContext]$context
    )

    Get-AzureStorageContainer `
        -Name $containerName `
        -Context $context `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentStorageContainer

    if ($notPresentStorageContainer) {
        Write-Host "[Output]:AzureStorageContainer with name: $containerName does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureStorageContainer with name: $containerName creating " -ForegroundColor DarkMagenta

        New-AzureStorageContainer -Name $containerName -Context $context -Permission blob  
    }
    else {
        Write-Host "[Output]:AzureStorageContainer with name: $containerName exists " -ForegroundColor DarkGreen
    }
}
function Get-SeAzureStorageBlobNames {
    param (
        [string]$containerName,
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.IStorageContext]$context
    )

    Write-Host "[Output]:[Start] AzureStorageBlob names are: " -ForegroundColor DarkGreen
    Get-AzureStorageBlob -Container $containerName -Context $ctx | select Name 
    Write-Host "[Output]:[End] AzureStorageBlob" -ForegroundColor DarkGreen
}
function Remove-IfExistsAzureStorageBlob {
    param (
        [string]$containerName,
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.IStorageContext]$context

    )
    Write-Host "[Output]: Removing AzureStorageContainer with name: $containerName if exists" -ForegroundColor DarkGreen
    Get-AzureStorageContainer `
        -Name $containerName `
        -Context $context `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentStorageContainer

    if (-not $notPresentStorageContainer) {
        Remove-AzureStorageContainer -Name $containerName -Context $context -Force
    }
    
}
function Get-LoginToAzureRm {
    $login = "a5f71341-8817-4dff-879e-a1a70cd70772"
    $secpasswd = ConvertTo-SecureString "BAWUCqNY3u8qMll450fTmIUlaVEzWFfJGcV50Y2dBbo=" -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential ($login, $secpasswd)

    Connect-AzureRmAccount `
        -ServicePrincipal `
        -Credential $mycreds `
        -TenantId "9b27efeb-3711-4191-8a0f-6b5317453890" `
        -Subscription "dd173c75-3d03-4114-9135-916d3e0db71e" `
        -EnvironmentName "AzureCloud" 
}
function Get-SeList2Task1 {
    param (
        [string]$path
    )

    Get-LoginToAzureRm

    Set-IfNotExistsAzureRmResourceGroup $resourceGroup $location
    $ctx = (Set-IfNotExistsAzureRmStorageAccount $resourceGroup $location $storageAccountName).Context

    Set-IfNotExistsAzureStorageContainer $containerName $ctx

    Get-SeAzureStorageBlobNames $containerName $ctx 

    Get-ChildItem -File -Recurse $path | ForEach-Object { 
        Set-AzureStorageBlobContent `
            -File $_.FullName `
            -Blob $_.FullName.Substring(3) `
            -Container $containerName `
            -Context $ctx 
    }

    Get-SeAzureStorageBlobNames $containerName $ctx 

    Remove-IfExistsAzureStorageBlob $containerName $ctx
}
function Set-IfNotExistsAzureRmSqlServer {
    param (
        [string]$servername,
        [System.Object]$sqlAdministratorCredentials
    )
    
    Get-AzureRmSqlServer `
        -ResourceGroupName $resourceGroup `
        -ServerName $servername `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentAzureRmSqlServer

    if ($notPresentAzureRmSqlServer) {
        Write-Host "[Output]:AzureRmSqlServer with name: $servername does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureRmSqlServer with name: $servername creating " -ForegroundColor DarkMagenta

        New-AzureRmSqlServer `
            -ResourceGroupName $resourceGroup `
            -ServerName $servername `
            -Location $location `
            -SqlAdministratorCredentials $sqlAdministratorCredentials
    }
    else {
        Write-Host "[Output]:AzureRmSqlServer with name: $servername exists " -ForegroundColor DarkGreen
    }
}
function Set-IfNotExistsAzureRmSqlServerFirewallRule {
    param (
        [string]$servername,
        [string]$firewallRuleName,
        [string]$startip,
        [string]$endip
    )

    Get-AzureRmSqlServerFirewallRule `
        -ResourceGroupName $resourceGroup `
        -ServerName $servername `
        -FirewallRuleName $firewallRuleName `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentAzureRmSqlServerFirewallRule

    if ($notPresentAzureRmSqlServerFirewallRule) {
        Write-Host "[Output]:AzureRmSqlServerFirewallRule with name: $firewallRuleName does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureRmSqlServerFirewallRule with name: $firewallRuleName creating " -ForegroundColor DarkMagenta

        New-AzureRmSqlServerFirewallRule `
            -ResourceGroupName $resourceGroup `
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
        [string]$databasename
    )

    Get-AzureRmSqlDatabase `
        -ResourceGroupName $resourceGroup `
        -ServerName $servername `
        -DatabaseName $databasename `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentAzureRmSqlServerFirewallRule

    if ($notPresentAzureRmSqlServerFirewallRule) {
        Write-Host "[Output]:AzureRmSqlDatabase with name: $databasename does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureRmSqlDatabase with name: $databasename creating " -ForegroundColor DarkMagenta

        New-AzureRmSqlDatabase `
            -ResourceGroupName $resourceGroup `
            -ServerName $servername `
            -DatabaseName $databasename `
            -RequestedServiceObjectiveName "S0" `
            -SampleName "AdventureWorksLT"
    }
    else {
        Write-Host "[Output]:AzureRmSqlDatabase with name: $databasename exists " -ForegroundColor DarkGreen
    }
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
function Set-IfNotExistsAzureRmSqlDatabaseImport {
    param (
        [string]$servername,
        [string]$databasename,
        [System.Object]$storageKey,
        [System.Object]$bacpacUri,
        [string]$adminlogin,
        [System.Object]$passwordSecure
    )

    Get-AzureRmSqlDatabase `
        -ResourceGroupName $resourceGroup `
        -ServerName $servername `
        -DatabaseName $databasename `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentAzureRmSqlDatabaseImport

    if ($notPresentAzureRmSqlDatabaseImport) {
        Write-Host "[Output]:AzureRmSqlDatabaseImport with name: $databasename does not exists " -ForegroundColor DarkGreen
        Write-Host "[Output]:AzureRmSqlDatabaseImport with name: $databasename creating " -ForegroundColor DarkMagenta

        $request = New-AzureRmSqlDatabaseImport `
            -ResourceGroupName $resourceGroup `
            -ServerName $servername `
            -DatabaseName $databasename `
            -DatabaseMaxSizeBytes "262144000" `
            -StorageKeyType "StorageAccessKey" `
            -StorageKey $storageKey `
            -StorageUri $bacpacUri `
            -Edition "Standard" `
            -ServiceObjectiveName "S3" `
            -AdministratorLogin "$adminlogin" `
            -AdministratorLoginPassword $passwordSecure

        Get-Status "import" $request.OperationStatusLink

        # Scale down to S0 after import is complete
        Write-Host "[Output]:AzureRmSqlDatabaseImport. Scale down to S0 after import is complete.." -ForegroundColor DarkGreen
        Set-AzureRmSqlDatabase `
            -ResourceGroupName $resourceGroup `
            -ServerName $servername `
            -DatabaseName $databasename  `
            -Edition "Standard" `
            -RequestedServiceObjectiveName "S0"
    }
    else {
        Write-Host "[Output]:AzureRmSqlDatabaseImport with name: $databasename exists. Bacpac can not be imported" -ForegroundColor DarkRed
    }
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
        -ResourceGroupName $resourceGroup `
        -ServerName $servername `
        -DatabaseName $databasename `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentAzureRmSqlDatabaseImport

    if (-not $notPresentAzureRmSqlDatabaseImport) {
        Write-Host "[Output]:IfExistsAzureRmSqlDatabaseExport with name: $databasename exists" -ForegroundColor DarkGreen
        Write-Host "[Output]:IfExistsAzureRmSqlDatabaseExport with name: $databasename exporting" -ForegroundColor DarkMagenta

        $request = New-AzureRmSqlDatabaseExport `
            -ResourceGroupName $resourceGroup `
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

function Get-AllAzureRmSqlDatabase {
    param (
        [string]$servername
    )
    
    Write-Host "[Output]:[Start] AzureRmSqlServer with name: $servername contains next databases: " -ForegroundColor DarkGreen
    Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroup -ServerName $servername 
    Write-Host "[Output]:[End] AzureRmSqlServer" -ForegroundColor DarkGreen
}
function Set-BacpacToBlob {
    param (
        [string]$pathToBacpac
    )
    Get-LoginToAzureRm
    Set-IfNotExistsAzureRmResourceGroup $resourceGroup $location
    $ctx = (Set-IfNotExistsAzureRmStorageAccount $resourceGroup $location $storageAccountName).Context
    Set-IfNotExistsAzureStorageContainer $containerName $ctx
    Get-SeAzureStorageBlobNames $containerName $ctx 
    $filepath = Get-ChildItem $pathToBacpac

    $res = Set-AzureStorageBlobContent `
        -File $pathToBacpac `
        -Blob $filepath.Name `
        -Container $containerName `
        -Context $ctx `
        -Force

    Get-SeAzureStorageBlobNames $containerName $ctx 
    Write-Host "[Output]: AzureStorageBlobContent url is: $($res.IcloudBlob.Uri.AbsoluteUri) " -ForegroundColor DarkGreen

    return [System.Uri]$res.IcloudBlob.Uri
}
function Get-SeList2Task2 {
    param (
        [string]$pathToBacpac
    )

    Get-LoginToAzureRm

    # Set an admin login and password for your server
    $adminlogin = "ServerAdmin"
    $password = "ChangeYourAdminPassword1"
    $passwordSecure = ConvertTo-SecureString -String $password -AsPlainText -Force
    $storageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName).Value[0]
    # Set server name - the logical server name has to be unique in the system
    # $servername = "server-$(Get-Random)"
    $servername = "server-devops"
    # The sample database name
    $databasename1 = "mySampleDatabase1"
    $databasename2 = "mySampleDatabase2"
    # The ip address range that you want to allow to access your server
    $firewallRuleName = "AllowedIPs"
    $ip = Invoke-RestMethod "http://ipinfo.io/json" | Select-Object -exp ip
    $startip = "0.0.0.0"
    $endip = $ip

    Set-IfNotExistsAzureRmResourceGroup $resourceGroup $location

    # Create a server with a system wide unique server name
    $sqlAdministratorCredentials = $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin, $passwordSecure)
    Set-IfNotExistsAzureRmSqlServer $servername  $sqlAdministratorCredentials

    # Create a server firewall rule that allows access from the specified IP range
    Set-IfNotExistsAzureRmSqlServerFirewallRule $servername $firewallRuleName $startip $endip

    # # Create a blank database with an S0 performance level
    Get-AllAzureRmSqlDatabase $servername
    Set-IfNotExistsAzureRmSqlDatabase $servername $databasename1
    Get-AllAzureRmSqlDatabase $servername

    $bacpacUriImport = Set-BacpacToBlob $pathToBacpac

    # Import bacpac to database with an S3 performance level
    Set-IfNotExistsAzureRmSqlDatabaseImport $servername $databasename2 $storageKey $bacpacUriImport[-1] $adminlogin $passwordSecure
    
    $databasenameExport = $databasename1
    $bacpacUriExport = "http://$storageAccountName.blob.core.windows.net/$containerName/$databasenameExport.bacpac"
    Set-IfExistsAzureRmSqlDatabaseExport $servername $databasenameExport $storageKey $bacpacUriExport $adminlogin $passwordSecure
}

function  Remove-AzureRmResourceGroup {
    Write-Host "[Output]: Remove-AzureRmResourceGroup" -ForegroundColor DarkGreen
    Remove-AzureRmResourceGroup -ResourceGroupName $resourceGroup -Force 
}