Describe "AzureConfig" -Tag "Security", "Network", "Azure", "Severity:Medium" {
    It "AZR.1005: Ensure WAF Policy is in Prevention Mode" -Tag "AZR.1005" {

        $Result = Test-MtWafPolicyPreventionMode

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "WAF Policy should be in Prevention Mode"
        }
    }
}
