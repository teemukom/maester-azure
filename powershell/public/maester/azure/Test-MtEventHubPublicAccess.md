Event Hub namespaces should disable public network access so that event streaming endpoints are not reachable from the internet and all clients must connect through private endpoints within a trusted virtual network.

### Remediation action:

1. In the [Azure portal](https://portal.azure.com), navigate to the Event Hubs namespace.
2. Select **Networking** in the left menu.
3. Under **Public access**, select **Disabled**.
4. Add a private endpoint under **Private endpoint connections** and link it to the appropriate virtual network and subnet.
5. Update application connection strings to use the private endpoint FQDN, then click **Save**.

Using Azure CLI:
`az eventhubs namespace update --name <namespace> --resource-group <rg> --public-network-access Disabled`

#### Related links

- [Network security for Azure Event Hubs](https://learn.microsoft.com/en-us/azure/event-hubs/network-security)

<!--- Results --->

%TestResult%
