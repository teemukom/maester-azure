<#
.SYNOPSIS
    Checks if all Bastion hosts are deployed with multiple availability zones

.DESCRIPTION
    This test ensures that all Bastion hosts have multiple availability zones configured
    by evaluating the `zones` property. Multiple availability zones provide higher availability
    and resilience against zone failures and are recommended for production deployments.
    security controls.

.EXAMPLE
    Test-MtBastionSKU

    Returns true if all Bastion hosts have multiple availability zones configured.

.LINK
    https://maester.dev/docs/commands/Test-MtBastionAvailabilityZones
#>
function Test-MtBastionAvailabilityZones {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Availability zones is an inherently plural Azure concept.')]
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $nonCompliantHosts = @()
    $resultsMarkdown = ""

    try {
        # Use Azure Resource Graph to get all Bastion hosts across all subscriptions with availability zone information
        $query = "Resources | where type =~ 'Microsoft.Network/bastionHosts' | project id, name, resourceGroup, subscriptionId, location, properties, zones"
        $bastionHosts = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get Bastion Hosts" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($bastionHosts.Count) Bastion hosts to check"

    foreach ($bastionHost in $bastionHosts) {
        try {
            $hostName = $bastionHost.name
            $hostRg = $bastionHost.resourceGroup
            $subId = $bastionHost.subscriptionId
            $zones = $bastionHost.zones

            Write-Verbose "Bastion host: $hostName, Zones: $($zones -join ', ')"

            # Check if multiple availability zones are configured
            $hasMultipleZones = $zones -and $zones.Count -gt 1

            if (-not $hasMultipleZones) {
                $nonCompliantHosts += $hostName
                $zoneInfo = if ($zones -and $zones.Count -eq 1) { "Single zone: $($zones[0])" } elseif (-not $zones) { "No zones configured" } else { "Invalid zone configuration" }
                $resultsMarkdown += "- $hostName (subscription: $subId, resource group: $hostRg) - $zoneInfo`n"
            }
            # Don't add anything for compliant hosts - only show non-compliant ones
        }
        catch {
            $nonCompliantHosts += $bastionHost.name
            $resultsMarkdown += "- Failed to check Bastion host $($bastionHost.name) in subscription $($bastionHost.subscriptionId): $($_.Exception.Message)`n"
            continue
        }
    }

    if (!$bastionHosts) {
        $testResult = $true
        $testResultMarkdown = "No Bastion hosts found"
    }
    else {
        $testResult = $nonCompliantHosts.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "Well done. All $($bastionHosts.Count) Bastion hosts have multiple availability zones."
        }
        else {
            $testResultMarkdown = "Not all Bastion hosts have multiple availability zones."
        }
        
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**Bastion Host Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}