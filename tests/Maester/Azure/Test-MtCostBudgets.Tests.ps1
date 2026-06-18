
Describe "AzureConfig" -Tag "Cost", "Azure", "CostOptimization", "Severity:Medium" {
    It "AZR.1020: Ensure at least one Cost Management budget has alerts configured" -Tag "AZR.1020" {

        $Result = Test-MtCostBudgets

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "At least one Cost Management budget should have enabled alerts"
        }
    }
}
