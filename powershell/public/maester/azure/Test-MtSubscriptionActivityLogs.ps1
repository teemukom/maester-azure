<#
.SYNOPSIS
    Checks if all subscriptions have activity logs forwarded to a Log Analytics workspace, Storage account or Event Hub

.DESCRIPTION
    This test ensures that all subscriptions have activity logs forwarded to a Log Analytics workspace, Storage account or Event Hub.
    Forwarding activity logs helps monitor and analyze subscription activities and is a recommended security control.

.EXAMPLE
    Test-MtSubscriptionActivityLogs
    Returns true if all subscriptions have activity logs forwarded to a Log Analytics workspace, Storage account or Event Hub.

.LINK
    https://maester.dev/docs/commands/Test-MtSubscriptionActivityLogs
#>
function Test-MtSubscriptionActivityLogs {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Activity logs is an inherently plural Azure concept.')]
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $nonCompliantSubscriptions = @()
    $resultsMarkdown = ""

    try {
        # Use Azure Resource Graph to get all subscriptions
        $query = "ResourceContainers | where type =~ 'microsoft.resources/subscriptions' | project id, name, subscriptionId"
        $subscriptions = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get subscriptions" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($subscriptions.Count) subscriptions to check"
    foreach ($sub in $subscriptions) {
        try {
            $diagSettings = Invoke-MtAzureRequest `
                -RelativeUri "subscriptions/$($sub.subscriptionId)/providers/microsoft.insights/diagnosticSettings" `
                -ApiVersion "2021-05-01-preview"

            $hasExport = $diagSettings.value.Count -gt 0
            if (-not $hasExport) {
                $nonCompliantSubscriptions += $sub.name
                $resultsMarkdown += "- Subscription $($sub.name) does not have activity logs forwarded.`n"
            }
        }
        catch {
            Write-Warning "Failed to check diagnostic settings for subscription '$($sub.name)': $($_.Exception.Message)"
            continue
        }
    }

    if (!$nonCompliantSubscriptions) {
        $testResult = $true
        $testResultMarkdown = "Well done. All subscriptions have activity logs forwarded."
    }
    else {
        $testResult = $false
        $testResultMarkdown = "Some subscriptions do not have activity logs forwarded."

        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**Subscription Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}