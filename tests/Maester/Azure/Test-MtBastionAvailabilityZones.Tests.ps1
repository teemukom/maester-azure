Describe "AzureConfig" -Tag "Bastion", "Azure", "Reliability", "Severity:Medium" {
    It "AZR.1018: Ensure Bastion is deployed to multiple availability zones" -Tag "AZR.1018" {

        $Result = Test-MtBastionAvailabilityZones

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Bastion must be deployed to multiple availability zones"
        }
    }
}
