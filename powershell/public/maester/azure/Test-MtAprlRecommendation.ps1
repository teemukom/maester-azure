<#
.SYNOPSIS
    Runs an APRL recommendation check using a bundled Azure Resource Graph query.

.DESCRIPTION
    Looks up the APRL recommendation GUID in the bundled catalog, executes its
    Azure Resource Graph query, and returns true when zero non-compliant resources
    are found. Zero rows returned by the ARG query means all resources are compliant.

    The catalog ships with the module — no internet connectivity required. To refresh
    the catalog from the upstream APRL GitHub repo, run Update-MtAprlCatalog.

.PARAMETER AprlGuid
    The APRL recommendation GUID, e.g. 'c72b7fee-1fa0-5b4b-98e5-54bcae95bb74'.

.EXAMPLE
    Test-MtAprlRecommendation -AprlGuid 'c72b7fee-1fa0-5b4b-98e5-54bcae95bb74'

    Returns true if all Azure Firewalls are deployed across multiple availability zones.

.LINK
    https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/
#>
function Test-MtAprlRecommendation {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$AprlGuid
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $Rec = Get-MtAprlCatalogEntry -AprlGuid $AprlGuid
    if ($null -eq $Rec) {
        Add-MtTestResultDetail -SkippedBecause Custom -SkippedCustomReason "APRL GUID '$AprlGuid' not found in catalog. Run Update-MtAprlCatalog to refresh."
        return $null
    }

    if (-not $Rec.HasAutomation) {
        Add-MtTestResultDetail -SkippedBecause Custom -SkippedCustomReason "This APRL recommendation requires manual verification. See $($Rec.LearnMoreUrl)"
        return $null
    }

    try {
        $NonCompliant = Invoke-MtAzureResourceGraphRequest -Query $Rec.Kql
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }

    $TestResult = $NonCompliant.Count -eq 0

    if ($TestResult) {
        $TestResultMarkdown = "Well done! No non-compliant resources found for: **$($Rec.Title)**"
    }
    else {
        $TestResultMarkdown = "Found **$($NonCompliant.Count)** non-compliant resource(s) for: **$($Rec.Title)**`n`n"
        $TestResultMarkdown += "| Resource | Details |`n|---|---|`n"
        foreach ($R in $NonCompliant) {
            $Detail = if ($R.PSObject.Properties['param1']) { [string]$R.param1 } else { '' }
            $TestResultMarkdown += "| $($R.name) | $Detail |`n"
        }
        $TestResultMarkdown += "`n> **Learn more:** [$($Rec.LearnMoreUrl)]($($Rec.LearnMoreUrl))"
    }

    Add-MtTestResultDetail -Result $TestResultMarkdown
    return $TestResult
}
