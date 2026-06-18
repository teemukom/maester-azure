Describe "AzureConfig" -Tag "PostgreSQL", "Azure", "Security", "Severity:Medium" {
    It "AZR.1008: Ensure PostgreSQL Server public network access is disabled" -Tag "AZR.1008" {

        $Result = Test-MtPostgreSqlServerPublicAccess

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "PostgreSQL Server must have public network access disabled"
        }
    }
}
