SQL Servers should disable public network access so that database connections cannot originate from the internet and must instead flow through private endpoints within a trusted virtual network.

### Remediation action:

1. In the [Azure portal](https://portal.azure.com), navigate to the SQL Server (logical server).
2. Select **Networking** under **Security** in the left menu.
3. On the **Connectivity** tab, set **Public network access** to **Disabled**.
4. Add a private endpoint under **Private endpoint connections** and link it to the appropriate virtual network and subnet.
5. Click **Save** and validate that applications can still connect via the private endpoint.

Using Azure CLI:
`az sql server update --name <server> --resource-group <rg> --set publicNetworkAccess="Disabled"`

#### Related links

- [Azure SQL Database and Azure Synapse connectivity settings](https://learn.microsoft.com/en-us/azure/azure-sql/database/connectivity-settings)

<!--- Results --->

%TestResult%
