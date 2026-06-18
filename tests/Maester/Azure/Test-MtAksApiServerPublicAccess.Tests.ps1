Describe "AzureConfig" -Tag "AKS", "Azure", "Security", "Severity:Medium" {
    It "AZR.1010: Ensure AKS clusters have private API server enabled" -Tag "AZR.1010" {

        $Result = Test-MtAksApiServerPublicAccess

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "AKS clusters must have private API server enabled"
        }
    }
}
