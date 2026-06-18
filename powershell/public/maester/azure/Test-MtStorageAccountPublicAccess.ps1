<#
.SYNOPSIS
    Checks if all Storage Accounts have public network access disabled

.DESCRIPTION
    This test ensures that all Storage Accounts have public network access disabled
    by evaluating the `publicNetworkAccess` property. Disabling public network access
    helps protect storage account data from unauthorized access and is a recommended
    security control.

.EXAMPLE
    Test-MtStorageAccountPublicAccess
    Returns true if all Storage Accounts have public network access disabled.

.LINK
    https://maester.dev/docs/commands/Test-MtStorageAccountPublicAccess
#>
function Test-MtStorageAccountPublicAccess {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $nonCompliantStorageAccounts = @()
    $resultsMarkdown = ""

    try {
        # Use Azure Resource Graph to get all Storage Accounts across all subscriptions
        $query = "Resources | where type =~ 'Microsoft.Storage/storageAccounts' | project id, name, resourceGroup, subscriptionId, location, properties"
        $storageAccounts = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get Storage Accounts" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($storageAccounts.Count) Storage Accounts to check"
    foreach ($storageAccount in $storageAccounts) {
        try {
            $accountName = $storageAccount.name
            $accountRg = $storageAccount.resourceGroup
            $subId = $storageAccount.subscriptionId

            # Check properties from the resource graph query first
            $publicNetworkAccess = $storageAccount.properties.publicNetworkAccess

            # If properties are not available from resource graph, get detailed vault info
            if ($null -eq $publicNetworkAccess) {
                $accountDetails = Invoke-MtAzureRequest `
                    -RelativeUri "/subscriptions/$subId/resourceGroups/$accountRg/providers/Microsoft.Storage/storageAccounts/$accountName" `
                    -ApiVersion "2023-05-01"
                
                $publicNetworkAccess = $accountDetails.properties.publicNetworkAccess
            }

            Write-Verbose "Storage Account: $accountName, Public Network Access: $publicNetworkAccess"

            # Check if public network access is disabled
            if ($publicNetworkAccess -ne "Disabled") {
                $nonCompliantStorageAccounts += $accountName
                $resultsMarkdown += "- $accountName (subscription: $subId, resource group: $accountRg) public network access is NOT disabled (State: $publicNetworkAccess).`n"
            }
            # Don't add anything for compliant accounts - only show non-compliant ones
        }
        catch {
            $nonCompliantStorageAccounts += $accountName
            $resultsMarkdown += "- Failed to check Storage Account $($accountName) in subscription $($subId): $($_.Exception.Message)`n"
            continue
        }
    }

    if (!$nonCompliantStorageAccounts) {
        $testResult = $true
        $testResultMarkdown = "No Storage Accounts found"
    }
    else {
        $testResult = $nonCompliantStorageAccounts.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "Well done. All $($storageAccounts.Count) Storage Accounts have public network access disabled."
        }
        else {
            $testResultMarkdown = "Some Storage Accounts do not have public network access disabled."
        }
        
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**Storage Account Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}