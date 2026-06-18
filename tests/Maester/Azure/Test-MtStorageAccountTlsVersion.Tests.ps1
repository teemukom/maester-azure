Describe "AzureConfig" -Tag "Security", "Storage", "Azure", "Severity:Medium" {
    It "AZR.1001: Enforce the latest TLS version for a storage account" -Tag "AZR.1001" {

        $Result = Test-MtStorageAccountTlsVersion

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "TLS versions should be compliant on all Storage Accounts"
        }
    }
}
