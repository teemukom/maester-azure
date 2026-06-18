<#
.SYNOPSIS
    Checks if all Key Vaults have public network access disabled

.DESCRIPTION
    This test ensures that all Key Vaults have public network access disabled
    by evaluating the `publicNetworkAccess` property. Disabling public network access
    helps protect key vault data from unauthorized access and is a recommended
    security control.

.EXAMPLE
    Test-MtKeyVaultPublicAccess

    Returns true if all Key Vaults have public network access disabled.

.LINK
    https://maester.dev/docs/commands/Test-MtKeyVaultPublicAccess
#>
function Test-MtKeyVaultPublicAccess {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $nonCompliantVaults = @()
    $resultsMarkdown = ""

    try {
        # Use Azure Resource Graph to get all Key Vaults across all subscriptions
        $query = "Resources | where type =~ 'Microsoft.KeyVault/vaults' | project id, name, resourceGroup, subscriptionId, location, properties"
        $keyVaults = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get Key vaults" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($keyVaults.Count) Key vaults to check"

    foreach ($keyVault in $keyVaults) {
        try {
            $vaultName = $keyVault.name
            $vaultRg = $keyVault.resourceGroup
            $subId = $keyVault.subscriptionId

            # Check properties from the resource graph query first
            $publicNetworkAccess = $keyVault.properties.publicNetworkAccess

            # If properties are not available from resource graph, get detailed vault info
            if ($null -eq $publicNetworkAccess) {
                $vaultDetails = Invoke-MtAzureRequest `
                    -RelativeUri "/subscriptions/$subId/resourceGroups/$vaultRg/providers/Microsoft.KeyVault/vaults/$vaultName" `
                    -ApiVersion "2023-07-01"
                
                $publicNetworkAccess = $vaultDetails.properties.publicNetworkAccess
            }

            Write-Verbose "Key vault: $vaultName, Public Network Access: $publicNetworkAccess"

            # Check if public network access is disabled
            if ($publicNetworkAccess -ne "Disabled") {
                $nonCompliantVaults += $vaultName
                $resultsMarkdown += "- $vaultName (subscription: $subId, resource group: $vaultRg) public network access is NOT disabled (State: $publicNetworkAccess).`n"
            }
            # Don't add anything for compliant vaults - only show non-compliant ones
        }
        catch {
            $nonCompliantVaults += $keyVault.name
            $resultsMarkdown += "- Failed to check Key vault $($keyVault.name) in subscription $($keyVault.subscriptionId): $($_.Exception.Message)`n"
            continue
        }
    }

    if (!$keyVaults) {
        $testResult = $true
        $testResultMarkdown = "No Key vaults found"
    }
    else {
        $testResult = $nonCompliantVaults.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "Well done. All $($keyVaults.Count) Key vaults have public network access disabled."
        }
        else {
            $testResultMarkdown = "Some Key vaults do not have public network access disabled."
        }
        
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**Key vault Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}