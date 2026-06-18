<#
.SYNOPSIS
    Checks if all Azure SQL Servers have public network access disabled

.DESCRIPTION
    This test ensures that all Azure SQL Servers have public network access disabled
    by evaluating the `publicNetworkAccess` property. Disabling public network access
    ensures that SQL databases can only be accessed through private endpoints, significantly
    reducing the attack surface and protecting sensitive data from unauthorized internet-based
    access attempts.

.EXAMPLE
    Test-MtSqlServerPublicAccess

    Returns true if all SQL Servers have public network access disabled.

.LINK
    https://maester.dev/docs/commands/Test-MtSqlServerPublicAccess
#>
function Test-MtSqlServerPublicAccess {
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
        # Use Azure Resource Graph to get all SQL Servers across all subscriptions with public network access information
        $query = "Resources | where type =~ 'Microsoft.Sql/servers' | project id, name, resourceGroup, subscriptionId, location, properties"
        $sqlServers = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get SQL Servers" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($sqlServers.Count) SQL Servers to check"

    foreach ($sqlServer in $sqlServers) {
        try {
            $serverName = $sqlServer.name
            $serverRg = $sqlServer.resourceGroup
            $subId = $sqlServer.subscriptionId
            $publicNetworkAccess = $sqlServer.properties.publicNetworkAccess

            Write-Verbose "SQL Server: $serverName, Public Network Access: $publicNetworkAccess"

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
            $nonCompliantServers += $sqlServer.name
            $resultsMarkdown += "- Failed to check SQL Server $($sqlServer.name) in subscription $($sqlServer.subscriptionId): $($_.Exception.Message)`n"
            continue
        }
    }

    if (!$sqlServers) {
        $testResult = $true
        $testResultMarkdown = "No SQL Servers found"
    }
    else {
        $testResult = $nonCompliantServers.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "Well done. All $($sqlServers.Count) SQL Servers have public network access disabled."
        }
        else {
            $testResultMarkdown = "Not all SQL Servers have public network access disabled."
        }
        
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**SQL Server Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}
