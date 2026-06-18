Cosmos DB accounts should disable public network access so that the database endpoint is not reachable from the internet and all traffic must flow through private endpoints within a trusted virtual network.

### Remediation action:

1. In the [Azure portal](https://portal.azure.com), navigate to the Cosmos DB account.
2. Select **Networking** in the left menu.
3. Under **Public network access**, select **Disabled**.
4. Add a private endpoint under **Private endpoint connections** and link it to the appropriate virtual network and subnet.
5. Click **Save** and verify that applications can still connect via the private endpoint.

Using Azure CLI:
`az cosmosdb update --name <account> --resource-group <rg> --public-network-access DISABLED`

#### Related links

- [Configure private endpoints for Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-private-endpoints)

<!--- Results --->

%TestResult%
