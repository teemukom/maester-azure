<#
.SYNOPSIS
    Checks for orphaned Azure resources that no longer serve an active purpose

.DESCRIPTION
    This test identifies orphaned Azure resources that have no active use.
    The following resource types are checked:

    - Unattached Managed Disks (diskState = Unattached)
    - Unassociated Standard SKU Public IP Addresses
    - Empty App Service Plans (zero apps deployed)
    - Managed Disk Snapshots whose source disk no longer exists

.EXAMPLE
    Test-MtOrphanedResources
    Returns true if no cost-incurring orphaned resources are found.

.LINK
    https://maester.dev/docs/commands/Test-MtOrphanedResources
#>
function Test-MtOrphanedResources {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $orphanedResources = @()
    $resultsMarkdown = ""

    # --- Unattached Managed Disks ---
    try {
        $diskQuery = @"
Resources
| where type =~ 'microsoft.compute/disks'
| where properties.diskState =~ 'Unattached'
| where sku.name !~ 'UltraSSD_LRS'
| project id, name, resourceGroup, subscriptionId, location, sku = sku.name, sizeGB = properties.diskSizeGB
"@
        $unattachedDisks = Invoke-MtAzureResourceGraphRequest -Query $diskQuery

        foreach ($disk in $unattachedDisks) {
            $orphanedResources += $disk.name
            $resultsMarkdown += "- **[Disk]** ``$($disk.name)`` — $($disk.sizeGB) GB ($($disk.sku)) in ``$($disk.resourceGroup)`` (sub: $($disk.subscriptionId))`n"
        }
    }
    catch {
        Write-Warning "Failed to query unattached managed disks: $($_.Exception.Message)"
    }

    # --- Unassociated Standard Public IP Addresses ---
    try {
        $pipQuery = @"
Resources
| where type =~ 'microsoft.network/publicipaddresses'
| where sku.name =~ 'Standard'
| where isnull(properties.ipConfiguration)
| project id, name, resourceGroup, subscriptionId, location
"@
        $orphanedPIPs = Invoke-MtAzureResourceGraphRequest -Query $pipQuery

        foreach ($pip in $orphanedPIPs) {
            $orphanedResources += $pip.name
            $resultsMarkdown += "- **[Public IP]** ``$($pip.name)`` in ``$($pip.resourceGroup)`` (sub: $($pip.subscriptionId))`n"
        }
    }
    catch {
        Write-Warning "Failed to query unassociated public IP addresses: $($_.Exception.Message)"
    }

    # --- Empty App Service Plans ---
    try {
        $aspQuery = @"
Resources
| where type =~ 'microsoft.web/serverfarms'
| where properties.numberOfSites == 0
| where sku.tier !~ 'Free'
| where sku.tier !~ 'Shared'
| project id, name, resourceGroup, subscriptionId, location, tier = sku.tier, skuName = sku.name
"@
        $emptyPlans = Invoke-MtAzureResourceGraphRequest -Query $aspQuery

        foreach ($plan in $emptyPlans) {
            $orphanedResources += $plan.name
            $resultsMarkdown += "- **[App Service Plan]** ``$($plan.name)`` ($($plan.tier)/$([string]$plan.skuName)) in ``$($plan.resourceGroup)`` (sub: $($plan.subscriptionId))`n"
        }
    }
    catch {
        Write-Warning "Failed to query empty App Service Plans: $($_.Exception.Message)"
    }

    # --- Disk Snapshots with No Existing Source Disk ---
    try {
        $snapshotQuery = @"
Resources
| where type =~ 'microsoft.compute/snapshots'
| extend sourceDiskId = tolower(tostring(properties.creationData.sourceResourceId))
| join kind=leftouter (
    Resources
    | where type =~ 'microsoft.compute/disks'
    | project diskId = tolower(id)
) on `$left.sourceDiskId == `$right.diskId
| where isempty(diskId)
| project id, name, resourceGroup, subscriptionId, location, sizeGB = properties.diskSizeGB
"@
        $orphanedSnapshots = Invoke-MtAzureResourceGraphRequest -Query $snapshotQuery

        foreach ($snapshot in $orphanedSnapshots) {
            $orphanedResources += $snapshot.name
            $resultsMarkdown += "- **[Snapshot]** ``$($snapshot.name)`` — $($snapshot.sizeGB) GB in ``$($snapshot.resourceGroup)`` (sub: $($snapshot.subscriptionId))`n"
        }
    }
    catch {
        Write-Warning "Failed to query disk snapshots: $($_.Exception.Message)"
    }

    $testResult = $orphanedResources.Count -eq 0

    if ($testResult) {
        $testResultMarkdown = "Well done. No orphaned resources were found."
    }
    else {
        $testResultMarkdown = "$($orphanedResources.Count) orphaned resource(s) found with no active use."

        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**Orphaned Resources:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Investigate -Result $testResultMarkdown
    return $testResult
}
