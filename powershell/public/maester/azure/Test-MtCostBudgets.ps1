<#
.SYNOPSIS
    Checks if at least one Azure Cost Management budget exists

.DESCRIPTION
    This test verifies that at least one Cost Management budget is configured by
    querying resources of type `Microsoft.Consumption/budgets`. Alert notification
    status is shown in the detail table for informational purposes but does not
    affect the pass/fail result.

.EXAMPLE
    Test-MtCostBudgets

    Returns true when at least one Cost Management budget exists.

.LINK
    https://maester.dev/docs/commands/Test-MtCostBudgets
#>
function Test-MtCostBudgets {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Budgets is an inherently plural concept for cost management.')]
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
        $query = "Resources | where type =~ 'Microsoft.Consumption/budgets' | project id, name, type, subscriptionId, resourceGroup, properties"
        $budgets = Invoke-MtAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-MtTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to query Cost Management budgets" -SkippedError $_
        return $null
    }

    $budgetCount = @($budgets).Count
    Write-Verbose "Found $budgetCount Cost Management budget(s)"
    $budgetsWithAlerts = @()
    $budgetsWithoutAlerts = @()

    foreach ($budget in @($budgets)) {
        $hasEnabledAlert = $false
        $notifications = $budget.properties.notifications

        if ($null -ne $notifications) {
            $notificationItems = @()

            if ($notifications -is [System.Collections.IDictionary]) {
                $notificationItems = @($notifications.Values)
            }
            elseif ($notifications -is [array]) {
                $notificationItems = @($notifications)
            }
            elseif ($notifications.PSObject -and $notifications.PSObject.Properties) {
                $notificationItems = @($notifications.PSObject.Properties | ForEach-Object { $_.Value })
            }

            foreach ($notification in $notificationItems) {
                try {
                    if ([System.Convert]::ToBoolean($notification.enabled)) {
                        $hasEnabledAlert = $true
                        break
                    }
                }
                catch {
                    continue
                }
            }
        }

        if ($hasEnabledAlert) {
            $budgetsWithAlerts += $budget
        }
        else {
            $budgetsWithoutAlerts += $budget
        }
    }

    $testResult = $budgetCount -gt 0

    if ($testResult) {
        $testResultMarkdown = "Well done. Found $budgetCount Cost Management budget(s). $(@($budgetsWithAlerts).Count) have enabled alert notifications."
    }
    else {
        $testResultMarkdown = "No Cost Management budgets found. Configure at least one budget to monitor and control spend."
    }

    if ($budgetCount -gt 0) {
        foreach ($budget in $budgetsWithAlerts) {
            $resultsMarkdown += "- $($budget.name) (subscription: $($budget.subscriptionId)) - alerts: enabled`n"
        }

        foreach ($budget in $budgetsWithoutAlerts) {
            $resultsMarkdown += "- $($budget.name) (subscription: $($budget.subscriptionId)) - alerts: not configured/enabled`n"
        }

        if ($resultsMarkdown) {
            $testResultMarkdown += "`n`n**Budget Details:**`n$resultsMarkdown"
        }
    }

    Add-MtTestResultDetail -Result $testResultMarkdown
    return $testResult
}
