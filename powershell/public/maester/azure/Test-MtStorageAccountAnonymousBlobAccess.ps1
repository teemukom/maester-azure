<#
.SYNOPSIS
    Checks if all Storage Accounts have anonymous public blob access disabled

.DESCRIPTION
    This test ensures that all Storage Accounts have anonymous public blob access
    disabled by evaluating the `allowBlobPublicAccess` property. This is a recommended
    security control to protect data in transit.

.EXAMPLE
    Test-MtStorageAccountAnonymousBlobAccess

    Returns true if all storage accounts have anonymous public blob access disabled.

.LINK
    https://maester.dev/docs/commands/Test-MtStorageAccountAnonymousBlobAccess
#>
function Test-MtStorageAccountAnonymousBlobAccess {
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
        $query = "Resources | where type =~ 'Microsoft.Storage/storageAccounts' | project id, name, resourceGroup, subscriptionId, location, allowBlobPublicAccess = properties.allowBlobPublicAccess"
        $storageAccounts = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get Storage Accounts" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($storageAccounts.Count) Storage Accounts to check"

    foreach ($account in $storageAccounts) {
        if ($account.allowBlobPublicAccess -eq $true) {
            $nonCompliantStorageAccounts += $account.name
            $resultsMarkdown += "- $($account.name) (subscription: $($account.subscriptionId), resource group: $($account.resourceGroup)) has anonymous public blob access enabled`n"
        }
    }

    if (!$storageAccounts) {
        $testResult = $true
        $testResultMarkdown = "No Storage Accounts found"
    }
    else {
        $testResult = $nonCompliantStorageAccounts.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "All Storage Accounts have anonymous public blob access disabled"
        }
        else {
            $testResultMarkdown = "All of the Storage Accounts do not have anonymous public blob access disabled"
        }
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**Storage account details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}