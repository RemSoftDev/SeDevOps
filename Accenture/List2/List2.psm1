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
        New-AzureRmResourceGroup -Name $resourceGroup -Location $location
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
        $storageAccount = 
        New-AzureRmStorageAccount `
            -ResourceGroupName $resourceGroup `
            -Name $storageAccountName `
            -Location $location `
            -SkuName Standard_LRS `
            -Kind Storage
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
        New-AzureStorageContainer -Name $containerName -Context $context -Permission blob  
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
    Write-Host "[Output]: Removing AzureStorageContainer with name: $containerName" -ForegroundColor DarkGreen
    Get-AzureStorageContainer `
        -Name $containerName `
        -Context $context `
        -ErrorAction SilentlyContinue `
        -ErrorVariable notPresentStorageContainer

    if (-not $notPresentStorageContainer) {
        Remove-AzureStorageContainer -Name $containerName -Context $context -Force
    }
    
}
function Get-SeList2Task1 {
    param (
        [string]$path
    )
    $login = "a5f71341-8817-4dff-879e-a1a70cd70772"
    $secpasswd = ConvertTo-SecureString "BAWUCqNY3u8qMll450fTmIUlaVEzWFfJGcV50Y2dBbo=" -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential ($login, $secpasswd)
    $resourceGroup = "DevOpsGroup"
    $location = "northeurope" 
    $storageAccountName = "devopsstorageaccount123"
    $containerName = "quickstartblobs"

    Connect-AzureRmAccount `
        -ServicePrincipal `
        -Credential $mycreds `
        -TenantId "9b27efeb-3711-4191-8a0f-6b5317453890" `
        -Subscription "dd173c75-3d03-4114-9135-916d3e0db71e" `
        -EnvironmentName "AzureCloud" 

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