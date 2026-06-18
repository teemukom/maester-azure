<#
.SYNOPSIS
    Checks if all Cosmos DB accounts have public network access disabled

.DESCRIPTION
    This test ensures that all Cosmos DB accounts have public network access disabled
    by evaluating the `publicNetworkAccess` property. Disabling public network access
    helps protect key vault data from unauthorized access and is a recommended
    security control.

.EXAMPLE
    Test-MtCosmosDbPublicAccess

    Returns true if all Cosmos DB accounts have public network access disabled.

.LINK
    https://maester.dev/docs/commands/Test-MtCosmosDbPublicAccess
#>
function Test-MtCosmosDbPublicAccess {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $nonCompliantCosmosDBAccounts = @()
    $resultsMarkdown = ""

    try {
        # Use Azure Resource Graph to get all Cosmos DB accounts across all subscriptions
        $query = "Resources | where type =~ 'Microsoft.DocumentDB/databaseAccounts' | project id, name, resourceGroup, subscriptionId, location, properties"
        $cosmosDBAccounts = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get Cosmos DB accounts" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($cosmosDBAccounts.Count) Cosmos DB accounts to check"
    foreach ($cosmosDBAccount in $cosmosDBAccounts) {
        try {
            $accountName = $cosmosDBAccount.name
            $accountRg = $cosmosDBAccount.resourceGroup
            $subId = $cosmosDBAccount.subscriptionId

            # Check properties from the resource graph query first
            $publicNetworkAccess = $cosmosDBAccount.properties.publicNetworkAccess

            # If properties are not available from resource graph, get detailed account info
            if ($null -eq $publicNetworkAccess) {
                $accountDetails = Invoke-MtAzureRequest `
                    -RelativeUri "/subscriptions/$subId/resourceGroups/$accountRg/providers/Microsoft.DocumentDB/databaseAccounts/$accountName" `
                    -ApiVersion "2023-07-01"
                
                $publicNetworkAccess = $accountDetails.properties.publicNetworkAccess
            }

            Write-Verbose "Cosmos DB account: $accountName, Public Network Access: $publicNetworkAccess"

            # Check if public network access is disabled
            if ($publicNetworkAccess -ne "Disabled") {
                $nonCompliantCosmosDBAccounts += $accountName
                $resultsMarkdown += "- $accountName (subscription: $subId, resource group: $accountRg) public network access is NOT disabled (State: $publicNetworkAccess).`n"
            }
            # Don't add anything for compliant accounts - only show non-compliant ones
        }
        catch {
            $nonCompliantCosmosDBAccounts += $accountName
            $resultsMarkdown += "- Failed to check Cosmos DB account $($accountName) in subscription $($subId): $($_.Exception.Message)`n"
            continue
        }
    }

    if (!$cosmosDBAccounts) {
        $testResult = $true
        $testResultMarkdown = "No Cosmos DB accounts found"
    }
    else {
        $testResult = $nonCompliantCosmosDBAccounts.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "All $($cosmosDBAccounts.Count) Cosmos DB accounts have public network access disabled."
        }
        else {
            $testResultMarkdown = "Some Cosmos DB accounts do not have public network access disabled."
        }
        
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**Cosmos DB Account Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}