Describe "AzureConfig" -Tag "Monitoring", "Azure", "Security", "OperationalExcellence", "Severity:High" {
    It "AZR.1027: Ensure all subscriptions have activity logs forwarded" -Tag "AZR.1027" {

        $Result = Test-MtSubscriptionActivityLogs

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "All subscriptions must have activity logs forwarded"
        }
    }
}
