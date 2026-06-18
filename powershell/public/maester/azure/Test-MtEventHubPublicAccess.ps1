<#
.SYNOPSIS
    Checks if all Azure Event Hubs namespaces have public network access disabled

.DESCRIPTION
    This test ensures that all Azure Event Hubs namespaces have public network access disabled
    by evaluating the `publicNetworkAccess` property. Disabling public network access
    ensures that Event Hubs can only be accessed through private endpoints, significantly
    reducing the attack surface and protecting sensitive event data from unauthorized internet-based
    access attempts.

.EXAMPLE
    Test-MtEventHubPublicAccess

    Returns true if all Event Hubs namespaces have public network access disabled.

.LINK
    https://maester.dev/docs/commands/Test-MtEventHubPublicAccess
#>
function Test-MtEventHubPublicAccess {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $nonCompliantNamespaces = @()
    $resultsMarkdown = ""

    try {
        # Use Azure Resource Graph to get all Event Hubs namespaces across all subscriptions with public network access information
        $query = "Resources | where type =~ 'Microsoft.EventHub/namespaces' | project id, name, resourceGroup, subscriptionId, location, properties"
        $eventHubNamespaces = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get Event Hubs namespaces" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($eventHubNamespaces.Count) Event Hubs namespaces to check"

    foreach ($namespace in $eventHubNamespaces) {
        try {
            $namespaceName = $namespace.name
            $namespaceRg = $namespace.resourceGroup
            $subId = $namespace.subscriptionId
            $publicNetworkAccess = $namespace.properties.publicNetworkAccess

            Write-Verbose "Event Hub Namespace: $namespaceName, Public Network Access: $publicNetworkAccess"

            # Check if public network access is disabled
            # Note: The property should be 'Disabled' for compliant configuration
            $isCompliant = $publicNetworkAccess -eq 'Disabled'

            if (-not $isCompliant) {
                $nonCompliantNamespaces += $namespaceName
                $accessStatus = if ($publicNetworkAccess) { "Public access: $publicNetworkAccess" } else { "Public access status: Unknown" }
                $resultsMarkdown += "- $namespaceName (subscription: $subId, resource group: $namespaceRg) - $accessStatus`n"
            }
            # Don't add anything for compliant namespaces - only show non-compliant ones
        }
        catch {
            $nonCompliantNamespaces += $namespace.name
            $resultsMarkdown += "- Failed to check Event Hub namespace $($namespace.name) in subscription $($namespace.subscriptionId): $($_.Exception.Message)`n"
            continue
        }
    }

    if (!$eventHubNamespaces) {
        $testResult = $true
        $testResultMarkdown = "No Event Hubs namespaces found"
    }
    else {
        $testResult = $nonCompliantNamespaces.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "Well done. All $($eventHubNamespaces.Count) Event Hubs namespaces have public network access disabled."
        }
        else {
            $testResultMarkdown = "Not all Event Hubs namespaces have public network access disabled."
        }
        
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**Event Hub Namespace Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}
