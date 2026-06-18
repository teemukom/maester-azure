<#
.SYNOPSIS
    Checks if all Azure SQL Managed Instances have public data endpoint disabled

.DESCRIPTION
    This test ensures that all Azure SQL Managed Instances have the public data endpoint disabled
    by evaluating the `publicDataEndpointEnabled` property. Disabling the public data endpoint
    ensures that SQL Managed Instances can only be accessed through virtual network connectivity,
    significantly reducing the attack surface and protecting sensitive data from unauthorized
    internet-based access attempts.

.EXAMPLE
    Test-MtSqlManagedInstancePublicAccess

    Returns true if all SQL Managed Instances have public data endpoint disabled.

.LINK
    https://maester.dev/docs/commands/Test-MtSqlManagedInstancePublicAccess
#>
function Test-MtSqlManagedInstancePublicAccess {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $nonCompliantInstances = @()
    $resultsMarkdown = ""

    try {
        # Use Azure Resource Graph to get all SQL Managed Instances across all subscriptions
        $query = "Resources | where type =~ 'Microsoft.Sql/managedInstances' | project id, name, resourceGroup, subscriptionId, location, properties"
        $sqlManagedInstances = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get SQL Managed Instances" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($sqlManagedInstances.Count) SQL Managed Instances to check"

    foreach ($instance in $sqlManagedInstances) {
        try {
            $instanceName = $instance.name
            $instanceRg = $instance.resourceGroup
            $subId = $instance.subscriptionId
            $publicDataEndpointEnabled = $instance.properties.publicDataEndpointEnabled

            Write-Verbose "SQL Managed Instance: $instanceName, Public Data Endpoint Enabled: $publicDataEndpointEnabled"

            # Check if public data endpoint is disabled
            # Note: The property should be false (or not present) for compliant configuration
            $isCompliant = $publicDataEndpointEnabled -eq $false -or $null -eq $publicDataEndpointEnabled

            if (-not $isCompliant) {
                $nonCompliantInstances += $instanceName
                $endpointStatus = if ($publicDataEndpointEnabled) { "Public data endpoint: Enabled" } else { "Public data endpoint: Unknown" }
                $resultsMarkdown += "- $instanceName (subscription: $subId, resource group: $instanceRg) - $endpointStatus`n"
            }
            # Don't add anything for compliant instances - only show non-compliant ones
        }
        catch {
            $nonCompliantInstances += $instance.name
            $resultsMarkdown += "- Failed to check SQL Managed Instance $($instance.name) in subscription $($instance.subscriptionId): $($_.Exception.Message)`n"
            continue
        }
    }

    if (!$sqlManagedInstances) {
        $testResult = $true
        $testResultMarkdown = "No SQL Managed Instances found"
    }
    else {
        $testResult = $nonCompliantInstances.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "All $($sqlManagedInstances.Count) SQL Managed Instances have public data endpoint disabled."
        }
        else {
            $testResultMarkdown = "Not all SQL Managed Instances have public data endpoint disabled."
        }
        
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**SQL Managed Instance Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}
