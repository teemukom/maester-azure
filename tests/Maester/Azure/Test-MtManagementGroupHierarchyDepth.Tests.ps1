Describe "AzureConfig" -Tag "ManagementGroup", "Azure", "Governance", "OperationalExcellence", "Severity:Low" {
    It "AZR.1024: Enforce reasonably flat management group hierarchy with no more than four levels" -Tag "AZR.1024" {

        $Result = Test-MtManagementGroupHierarchyDepth

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "A flat management group hierarchy (≤4 levels) improves governance, policy management, and operational efficiency"
        }
    }
}
