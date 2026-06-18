<#
.SYNOPSIS
    Checks if all WAF policies are in Prevention Mode

.DESCRIPTION
    This test ensures that all WAF policies are in Prevention Mode by evaluating the
    `mode` property. This is a recommended security control to protect applications
    from malicious traffic.

.EXAMPLE
    Test-MtWafPolicyPreventionMode

    Returns true if all WAF policies are in Prevention Mode.

.LINK
    https://maester.dev/docs/commands/Test-MtWafPolicyPreventionMode
#>
function Test-MtWafPolicyPreventionMode {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $nonCompliantWAFPolicies = @()
    $resultsMarkdown = ""

    try {
        # Use Azure Resource Graph to get all WAF policies across all subscriptions
        $agwquery = "Resources | where type =~ 'Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies' | project id, name, resourceGroup, subscriptionId, location, mode = properties.policySettings.mode"
        $agwPolicies = Invoke-MtAzureResourceGraphRequest -Query $agwquery

        $fdquery = "Resources | where type =~ 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies' | project id, name, resourceGroup, subscriptionId, location, mode = properties.policySettings.mode"
        $fdPolicies = Invoke-MtAzureResourceGraphRequest -Query $fdquery
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get WAF Policies" -SkippedError $_
        return $null
    }

        Write-Verbose "Found $($agwPolicies.Count) WAF Policies to check"

    foreach ($policy in $agwPolicies) {
        $mode = [string]$policy.mode
        if (-not $mode) { $mode = "Unknown" }
        if ($mode -ne "Prevention") {
            $nonCompliantWAFPolicies += $policy.name
            $resultsMarkdown += "- $($policy.name) (subscription: $($policy.subscriptionId), resource group: $($policy.resourceGroup)) is not in Prevention mode (state: $mode)`n"
        }
    }

    foreach ($policy in $fdPolicies) {
        $mode = [string]$policy.mode
        if (-not $mode) { $mode = "Unknown" }
        if ($mode -ne "Prevention") {
            $nonCompliantWAFPolicies += $policy.name
            $resultsMarkdown += "- $($policy.name) (subscription: $($policy.subscriptionId), resource group: $($policy.resourceGroup)) is not in Prevention mode (state: $mode)`n"
        }
    }

    if (!$agwPolicies -and !$fdPolicies) {
        $testResult = $true
        $testResultMarkdown = "No WAF Policies found."
    }
    elseif ($nonCompliantWAFPolicies.Count -eq 0) {
        $testResult = $true
        $testResultMarkdown = "Well done. All WAF Policies are in Prevention mode."
    }
    else {
        $testResult = $false
        $testResultMarkdown = "Found $($nonCompliantWAFPolicies.Count) WAF Policies not in Prevention mode."
        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**WAF policy details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}