Describe "AzureConfig" -Tag "CosmosDB", "Azure", "Security", "Severity:Medium" {
    It "AZR.1011: Ensure all Cosmos DB accounts have public network access disabled" -Tag "AZR.1011" {

        $Result = Test-MtCosmosDbPublicAccess

        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Cosmos DB accounts must have public network access disabled"
        }
    }
}
