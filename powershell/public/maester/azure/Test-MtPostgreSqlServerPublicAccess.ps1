<#
.SYNOPSIS
    Checks if all Azure PostgreSQL Servers have public network access disabled

.DESCRIPTION
    This test ensures that all Azure PostgreSQL Flexible Servers have public network access disabled
    by evaluating the `publicNetworkAccess` property. Disabling public network access
    ensures that PostgreSQL databases can only be accessed through private endpoints, significantly
    reducing the attack surface and protecting sensitive data from unauthorized internet-based
    access attempts.

.EXAMPLE
    Test-MtPostgreSqlServerPublicAccess

    Returns true if all PostgreSQL Servers have public network access disabled.

.LINK
    https://maester.dev/docs/commands/Test-MtPostgreSqlServerPublicAccess
#>
function Test-MtPostgreSqlServerPublicAccess {
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
        # Use Azure Resource Graph to get all PostgreSQL Flexible Servers across all subscriptions with public network access information
        $query = "Resources | where type =~ 'Microsoft.DBforPostgreSQL/flexibleServers' | project id, name, resourceGroup, subscriptionId, location, properties"
        $postgresqlServers = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get PostgreSQL Servers" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($postgresqlServers.Count) PostgreSQL Flexible Servers to check"

    foreach ($postgresqlServer in $postgresqlServers) {
        try {
            $serverName = $postgresqlServer.name
            $serverRg = $postgresqlServer.resourceGroup
            $subId = $postgresqlServer.subscriptionId
            $publicNetworkAccess = $postgresqlServer.properties.network.publicNetworkAccess

            Write-Verbose "PostgreSQL Server: $serverName, Public Network Access: $publicNetworkAccess"

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
            $nonCompliantServers += $postgresqlServer.name
            $resultsMarkdown += "- Failed to check PostgreSQL Server $($postgresqlServer.name) in subscription $($postgresqlServer.subscriptionId): $($_.Exception.Message)`n"
            continue
        }
    }

    if (!$postgresqlServers) {
        $testResult = $true
        $testResultMarkdown = "No PostgreSQL Flexible Servers found"
    }
    else {
        $testResult = $nonCompliantServers.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "All $($postgresqlServers.Count) PostgreSQL Flexible Servers have public network access disabled."
        }
        else {
            $testResultMarkdown = "Not all PostgreSQL Flexible Servers have public network access disabled."
        }
        
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**PostgreSQL Server Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}
