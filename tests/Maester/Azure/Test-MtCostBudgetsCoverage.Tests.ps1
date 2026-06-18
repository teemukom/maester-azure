
Describe "AzureConfig" -Tag "Cost", "Azure", "CostOptimization", "Severity:Medium" {
    It "AZR.1021: Ensure every enabled subscription has at least one budget with alerts configured" -Tag "AZR.1021" {

        $Result = Test-MtCostBudgetsCoverage

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Each enabled subscription should have at least one Cost Management budget with enabled alerts"
        }
    }
}
