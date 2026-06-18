MySQL Flexible Servers should disable public network access so that database connections cannot originate from the internet and must instead flow through private endpoints within a trusted virtual network.

### Remediation action:

1. In the [Azure portal](https://portal.azure.com), navigate to the MySQL Flexible Server.
2. Select **Networking** under **Settings** in the left menu.
3. Set **Connectivity method** to **Private access (VNet Integration)** or disable public access if a private endpoint is already configured.
4. Configure a private endpoint or VNet integration subnet and click **Save**.
5. Update application connection strings to use the private hostname and validate connectivity.

Using Azure CLI:
`az mysql flexible-server update --name <server> --resource-group <rg> --public-access Disabled`

#### Related links

- [Private networking concepts for Azure Database for MySQL Flexible Server](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-networking-private)

<!--- Results --->

%TestResult%
