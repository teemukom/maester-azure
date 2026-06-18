Describe "AzureConfig" -Tag "Security", "Storage", "Azure", "Severity:Medium" {
    It "AZR.1002: Check for Anonymous Public Blob Access" -Tag "AZR.1002" {

        $Result = Test-MtStorageAccountAnonymousBlobAccess

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Anonymous public blob access should be disabled on all Storage Accounts"
        }
    }
}
