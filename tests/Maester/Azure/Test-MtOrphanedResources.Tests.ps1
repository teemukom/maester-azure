Describe "AzureConfig" -Tag "CostOptimization", "Azure", "WAF", "Severity:Low" {
    It "AZR.1023: Ensure no cost-incurring orphaned resources exist" -Tag "AZR.1023" {

        $Result = Test-MtOrphanedResources

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Orphaned resources incur unnecessary costs and should be removed"
        }
    }
}
