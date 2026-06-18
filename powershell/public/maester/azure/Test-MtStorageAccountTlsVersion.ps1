<#
.SYNOPSIS
    Checks if all Storage Accounts have minimum compliant TLS version enabled

.DESCRIPTION
    This test ensures that all Storage Accounts have minimum compliant TLS version
    enabled by evaluating the `minimumTlsVersion` property. This is a recommended
    security control to protect data in transit.

.EXAMPLE
    Test-MtStorageAccountTlsVersion

    Returns true if all storage accounts have minimum compliant TLS version enabled.

.LINK
    https://maester.dev/docs/commands/Test-MtStorageAccountTlsVersion
#>
function Test-MtStorageAccountTlsVersion {
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
        $query = "Resources | where type =~ 'Microsoft.Storage/storageAccounts' | project id, name, resourceGroup, subscriptionId, location, minimumTlsVersion = properties.minimumTlsVersion"
        $storageAccounts = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get Storage Accounts" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($storageAccounts.Count) Storage Accounts to check"

    foreach ($account in $storageAccounts) {
        $minimumTlsVersion = [string]$account.minimumTlsVersion
        if (-not $minimumTlsVersion) {
            $minimumTlsVersion = "Unknown"
        }
        if ($minimumTlsVersion -ne "TLS1_2" -and $minimumTlsVersion -ne "TLS1_3") {
            $nonCompliantStorageAccounts += $account.name
            $resultsMarkdown += "- $($account.name) (subscription: $($account.subscriptionId), resource group: $($account.resourceGroup)) has unsupported TLS version (state: $minimumTlsVersion)`n"
        }
    }

    if (!$storageAccounts) {
        $testResult = $true
        $testResultMarkdown = "No Storage Accounts found"
    }
    else {
        $testResult = $nonCompliantStorageAccounts.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "Well done. All Storage Accounts enforce a supported TLS version."
        }
        else {
            $testResultMarkdown = "Not all Storage Accounts enforce the latest TLS version."
        }
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**Storage account details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}