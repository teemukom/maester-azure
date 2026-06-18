Describe "AzureConfig" -Tag "MySQL", "Azure", "Security", "Severity:Medium" {
    It "AZR.1007: Ensure MySQL Server public network access is disabled" -Tag "AZR.1007" {

        $Result = Test-MtMySqlServerPublicAccess

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "MySQL Server must have public network access disabled"
        }
    }
}
