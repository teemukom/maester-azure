Describe "AzureConfig" -Tag "EventHub", "Azure", "Security", "Severity:Medium" {
    It "AZR.1012: Ensure Event Hub namespace public network access is disabled" -Tag "AZR.1012" {

        $Result = Test-MtEventHubPublicAccess

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Event Hub namespace must have public network access disabled"
        }
    }
}
