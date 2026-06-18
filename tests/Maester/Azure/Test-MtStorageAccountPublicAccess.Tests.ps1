Describe "AzureConfig" -Tag "Storage", "Azure", "Security", "Severity:Medium" {
    It "AZR.1003: Ensure all Storage Accounts have public network access disabled" -Tag "AZR.1003" {

        $Result = Test-MtStorageAccountPublicAccess

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Storage Accounts must have public network access disabled"
        }
    }
}
