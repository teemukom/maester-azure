<#
.SYNOPSIS
    Checks if all Azure Kubernetes Service clusters have private API server enabled

.DESCRIPTION
    This test ensures that all Azure Kubernetes Service (AKS) clusters have private cluster mode enabled
    by evaluating the `apiServerAccessProfile.enablePrivateCluster` property. Enabling private cluster mode
    ensures that the Kubernetes API server can only be accessed through virtual network connectivity,
    significantly reducing the attack surface and protecting cluster operations from unauthorized
    internet-based access attempts.

.EXAMPLE
    Test-MtAksApiServerPublicAccess

    Returns true if all AKS clusters have private API server enabled.

.LINK
    https://maester.dev/docs/commands/Test-MtAksApiServerPublicAccess
#>
function Test-MtAksApiServerPublicAccess {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $nonCompliantClusters = @()
    $resultsMarkdown = ""

    try {
        # Use Azure Resource Graph to get all AKS clusters across all subscriptions
        $query = "Resources | where type =~ 'Microsoft.ContainerService/managedClusters' | project id, name, resourceGroup, subscriptionId, location, properties"
        $aksClusters = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get AKS clusters" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($aksClusters.Count) AKS clusters to check"

    foreach ($cluster in $aksClusters) {
        try {
            $clusterName = $cluster.name
            $clusterRg = $cluster.resourceGroup
            $subId = $cluster.subscriptionId
            $enablePrivateCluster = $cluster.properties.apiServerAccessProfile.enablePrivateCluster

            Write-Verbose "AKS Cluster: $clusterName, Enable Private Cluster: $enablePrivateCluster"

            # Check if private cluster is enabled
            # Note: The property should be true for compliant configuration
            $isCompliant = $enablePrivateCluster -eq $true

            if (-not $isCompliant) {
                $nonCompliantClusters += $clusterName
                $accessStatus = if ($enablePrivateCluster -eq $false) { "Private cluster: Disabled (Public API server)" } else { "Private cluster: Unknown/Not configured" }
                $resultsMarkdown += "- $clusterName (subscription: $subId, resource group: $clusterRg) - $accessStatus`n"
            }
            # Don't add anything for compliant clusters - only show non-compliant ones
        }
        catch {
            $nonCompliantClusters += $cluster.name
            $resultsMarkdown += "- Failed to check AKS cluster $($cluster.name) in subscription $($cluster.subscriptionId): $($_.Exception.Message)`n"
            continue
        }
    }

    if (!$aksClusters) {
        $testResult = $true
        $testResultMarkdown = "No AKS clusters found"
    }
    else {
        $testResult = $nonCompliantClusters.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "All $($aksClusters.Count) AKS clusters have private API server enabled."
        }
        else {
            $testResultMarkdown = "Not all AKS clusters have private API server enabled."
        }
        
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**AKS Cluster Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}
