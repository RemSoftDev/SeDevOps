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