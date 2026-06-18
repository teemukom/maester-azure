Describe "AzureConfig" -Tag "SQL", "Azure", "Security", "Severity:Medium" {
    It "AZR.1006: Ensure SQL Server public network access is disabled" -Tag "AZR.1006" {

        $Result = Test-MtSqlServerPublicAccess

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "SQL Server must have public network access disabled"
        }
    }
}
