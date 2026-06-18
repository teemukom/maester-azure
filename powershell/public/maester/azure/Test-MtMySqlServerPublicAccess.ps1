<#
.SYNOPSIS
    Checks if all Azure MySQL Servers have public network access disabled

.DESCRIPTION
    This test ensures that all Azure MySQL Flexible Servers have public network access disabled
    by evaluating the `publicNetworkAccess` property. Disabling public network access
    ensures that MySQL databases can only be accessed through private endpoints, significantly
    reducing the attack surface and protecting sensitive data from unauthorized internet-based
    access attempts.

.EXAMPLE
    Test-MtMySqlServerPublicAccess

    Returns true if all MySQL Servers have public network access disabled.

.LINK
    https://maester.dev/docs/commands/Test-MtMySqlServerPublicAccess
#>
function Test-MtMySqlServerPublicAccess {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $nonCompliantServers = @()
    $resultsMarkdown = ""

    try {
        # Use Azure Resource Graph to get all MySQL Flexible Servers across all subscriptions with public network access information
        $query = "Resources | where type =~ 'Microsoft.DBforMySQL/flexibleServers' | project id, name, resourceGroup, subscriptionId, location, properties"
        $mysqlServers = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get MySQL Servers" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($mysqlServers.Count) MySQL Flexible Servers to check"

    foreach ($mysqlServer in $mysqlServers) {
        try {
            $serverName = $mysqlServer.name
            $serverRg = $mysqlServer.resourceGroup
            $subId = $mysqlServer.subscriptionId
            $publicNetworkAccess = $mysqlServer.properties.network.publicNetworkAccess

            Write-Verbose "MySQL Server: $serverName, Public Network Access: $publicNetworkAccess"

            # Check if public network access is disabled
            # Note: The property should be 'Disabled' for compliant configuration
            $isCompliant = $publicNetworkAccess -eq 'Disabled'

            if (-not $isCompliant) {
                $nonCompliantServers += $serverName
                $accessStatus = if ($publicNetworkAccess) { "Public access: $publicNetworkAccess" } else { "Public access status: Unknown" }
                $resultsMarkdown += "- $serverName (subscription: $subId, resource group: $serverRg) - $accessStatus`n"
            }
            # Don't add anything for compliant servers - only show non-compliant ones
        }
        catch {
            $nonCompliantServers += $mysqlServer.name
            $resultsMarkdown += "- Failed to check MySQL Server $($mysqlServer.name) in subscription $($mysqlServer.subscriptionId): $($_.Exception.Message)`n"
            continue
        }
    }

    if (!$mysqlServers) {
        $testResult = $true
        $testResultMarkdown = "No MySQL Flexible Servers found"
    }
    else {
        $testResult = $nonCompliantServers.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "Well done. All $($mysqlServers.Count) MySQL Flexible Servers have public network access disabled."
        }
        else {
            $testResultMarkdown = "Not all MySQL Flexible Servers have public network access disabled."
        }
        
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**MySQL Server Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}
