Describe "AzureConfig" -Tag "SQLManagedInstance", "Azure", "Security", "Severity:Medium" {
    It "AZR.1009: Ensure SQL Managed Instance public data endpoint is disabled" -Tag "AZR.1009" {

        $Result = Test-MtSqlManagedInstancePublicAccess

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "SQL Managed Instance must have public data endpoint disabled"
        }
    }
}
