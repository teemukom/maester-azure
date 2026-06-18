<#
.SYNOPSIS
    Checks if the management group hierarchy depth does not exceed four levels

.DESCRIPTION
    This test ensures that the Azure management group hierarchy remains reasonably flat
    with no more than four levels below the tenant root group. Deep hierarchies can lead
    to complexity in policy management, troubleshooting, and governance. The test uses
    the management group path property to calculate the depth of each management group.

    Depth calculation:
    - Level 1: Tenant Root Group (path length = 1, includes self)
    - Level 2: Direct children of root (path length = 2)
    - Level 3: Grandchildren (path length = 3)
    - Level 4: Great-grandchildren (path length = 4) - Maximum allowed
    - Level 5+: Non-compliant (path length > 4)

.EXAMPLE
    Test-MtManagementGroupHierarchyDepth

    Returns true if all management groups are at level 4 or below.

.LINK
    https://maester.dev/docs/commands/Test-MtManagementGroupHierarchyDepth
#>
function Test-MtManagementGroupHierarchyDepth {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $deepManagementGroups = @()
    $allManagementGroups = @()
    $resultsMarkdown = ""
    $maxAllowedDepth = 4  # Maximum 4 levels allowed

    try {
        # Query all management groups and get their hierarchy depth
        # The managementGroupAncestorsChain contains ancestor MGs from immediate parent to root
        # Hierarchy depth = array_length(ancestors) + 1 (to include the MG itself)
        $query = @"
ResourceContainers 
| where type =~ 'microsoft.management/managementgroups' 
| extend ancestorsChain = properties.details.managementGroupAncestorsChain
| extend hierarchyDepth = array_length(ancestorsChain) + 1
| project id, name, displayName = properties.displayName, hierarchyDepth, ancestorsChain
| order by hierarchyDepth desc
"@
        $allManagementGroups = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to query management groups" -SkippedError $_
        return $null
    }

    if ($null -eq $allManagementGroups -or $allManagementGroups.Count -eq 0) {
        # No management groups found (unusual but possible in test environments)
        $testResult = $true
        $testResultMarkdown = "No management groups found to evaluate."
        Add-MtTestResultDetail -Result $testResultMarkdown
        return $testResult
    }

    Write-Verbose "Found $($allManagementGroups.Count) management groups to evaluate"

    # Identify management groups that exceed the depth limit
    foreach ($mg in $allManagementGroups) {
        $displayName = if ($mg.displayName) { $mg.displayName } else { $mg.name }
        $depth = [int]$mg.hierarchyDepth
        
        Write-Verbose "Management Group: $displayName, Depth: $depth"

        if ($depth -gt $maxAllowedDepth) {
            $deepManagementGroups += [PSCustomObject]@{
                Name        = $mg.name
                DisplayName = $displayName
                Depth       = $depth
                Path        = ($mg.ancestorsChain | ForEach-Object { $_.name }) -join " > "
            }
            
                $pathDisplay = ($mg.ancestorsChain | ForEach-Object { $_.name }) -join " → "
                $resultsMarkdown += "| $displayName | $($mg.name) | $depth | $pathDisplay |`n"
        }
    }

    $maxDepthFound = ($allManagementGroups | Measure-Object -Property hierarchyDepth -Maximum).Maximum

    if ($deepManagementGroups.Count -eq 0) {
        $testResult = $true
        $testResultMarkdown = "Well done. All management groups are within the recommended hierarchy depth.`n`n"
        $testResultMarkdown += "- **Total Management Groups**: $($allManagementGroups.Count)`n"
        $testResultMarkdown += "- **Maximum Depth Found**: $maxDepthFound levels`n"
        $testResultMarkdown += "- **Maximum Allowed Depth**: $maxAllowedDepth levels"
    }
    else {
        $testResult = $false
        $testResultMarkdown = "Found $($deepManagementGroups.Count) management group(s) exceeding the maximum hierarchy depth of $maxAllowedDepth levels.`n`n"
        $testResultMarkdown += "- **Total Management Groups**: $($allManagementGroups.Count)`n"
        $testResultMarkdown += "- **Maximum Depth Found**: $maxDepthFound levels`n"
        $testResultMarkdown += "- **Non-Compliant Groups**: $($deepManagementGroups.Count)`n"
        
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n**Management Groups Exceeding Depth Limit:**`n`n"
            $testResultMarkdown += "| Display Name | Name | Depth | Hierarchy Path |`n"
            $testResultMarkdown += "|--------------|------|-------|----------------|`n"
            $testResultMarkdown += $resultsMarkdown
        }
        
        $testResultMarkdown += "`n`n**Remediation**: Review and flatten your management group hierarchy. Consider consolidating management groups or moving subscriptions to reduce depth."
    }

    Add-MtTestResultDetail -Result $testResultMarkdown

    return $testResult
}
