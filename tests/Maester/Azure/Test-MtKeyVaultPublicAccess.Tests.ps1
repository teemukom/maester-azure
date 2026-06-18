Describe "AzureConfig" -Tag "Keyvault", "Azure", "Security", "Severity:Medium" {
    It "AZR.1004: Ensure all Key vaults have public network access disabled" -Tag "AZR.1004" {

        $Result = Test-MtKeyVaultPublicAccess

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Key vaults must have public network access disabled"
        }
    }
}
