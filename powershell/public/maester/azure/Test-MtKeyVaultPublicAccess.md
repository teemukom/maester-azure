Key Vaults should disable public network access so that secrets, keys, and certificates are only reachable through private endpoints within a trusted virtual network, reducing the risk of credential exfiltration.

### Remediation action:

1. In the [Azure portal](https://portal.azure.com), navigate to the Key Vault.
2. Select **Networking** in the left menu.
3. Under **Firewalls and virtual networks**, set **Allow access from** to **Disabled (no access)**, or use **Private endpoint only**.
4. Add a private endpoint under **Private endpoint connections** and link it to the appropriate virtual network and subnet.
5. Click **Save** and validate that applications can still retrieve secrets via the private endpoint.

Using Azure CLI:
`az keyvault update --name <vault> --resource-group <rg> --public-network-access Disabled`

#### Related links

- [Azure Key Vault network security](https://learn.microsoft.com/en-us/azure/key-vault/general/network-security)

<!--- Results --->

%TestResult%
