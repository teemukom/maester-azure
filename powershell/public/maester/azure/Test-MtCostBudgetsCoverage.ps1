<#
.SYNOPSIS
    Checks if every active Azure subscription has a Cost Management budget

.DESCRIPTION
    This test validates budget coverage by ensuring each enabled subscription
    has at least one Cost Management budget configured. Alert notification status
    is shown in the detail table for informational purposes but does not affect
    the pass/fail result.

.EXAMPLE
    Test-MtCostBudgetsCoverage

    Returns true when every enabled subscription has at least one budget.

.LINK
    https://maester.dev/docs/commands/Test-MtCostBudgetsCoverage
#>
function Test-MtCostBudgetsCoverage {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    if (!(Test-MtConnection Azure)) {
        Add-MtTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $resultsMarkdown = ""

    try {
        $subscriptionsQuery = "ResourceContainers | where type =~ 'microsoft.resources/subscriptions' | where properties.state =~ 'Enabled' | project subscriptionId, name"
        $enabledSubscriptions = Invoke-MtAzureResourceGraphRequest -Query $subscriptionsQuery
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to query subscriptions" -SkippedError $_
        return $null
    }

    try {
        $budgetsQuery = "Resources | where type =~ 'Microsoft.Consumption/budgets' | project id, name, subscriptionId, properties"
        $budgets = Invoke-MtAzureResourceGraphRequest -Query $budgetsQuery
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to query Cost Management budgets" -SkippedError $_
        return $null
    }

    $subscriptionCount = @($enabledSubscriptions).Count

    if ($subscriptionCount -eq 0) {
        Add-MtTestResultDetail -Result "No enabled subscriptions found."
        return $true
    }

    $coverageBySubscription = @{}
    foreach ($subscription in $enabledSubscriptions) {
        $coverageBySubscription[$subscription.subscriptionId] = $false
    }

    foreach ($budget in @($budgets)) {
        $subId = $budget.subscriptionId
        if ([string]::IsNullOrWhiteSpace($subId)) { continue }
        if (-not $coverageBySubscription.ContainsKey($subId)) { continue }
        $coverageBySubscription[$subId] = $true
    }

    $subscriptionsMissingCoverage = @()
    foreach ($subscription in $enabledSubscriptions) {
        if (-not $coverageBySubscription[$subscription.subscriptionId]) {
            $subscriptionsMissingCoverage += $subscription
        }
    }

    $coveredCount = $subscriptionCount - @($subscriptionsMissingCoverage).Count
    $testResult = @($subscriptionsMissingCoverage).Count -eq 0

    if ($testResult) {
        $testResultMarkdown = "All $subscriptionCount enabled subscription(s) have at least one Cost Management budget."
    }
    else {
        $testResultMarkdown = "$coveredCount of $subscriptionCount enabled subscription(s) have at least one Cost Management budget."
    }

    foreach ($subscription in $enabledSubscriptions) {
        $status = if ($coverageBySubscription[$subscription.subscriptionId]) { 'has budget' } else { 'no budget found' }
        $resultsMarkdown += "- $($subscription.name) ($($subscription.subscriptionId)): $status`n"
    }

        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**Subscription Coverage Details:**`n$resultsMarkdown"
        }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}
