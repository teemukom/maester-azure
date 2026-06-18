Azure Bastion should be deployed with zone redundancy so that secure RDP and SSH access to virtual machines remains available even when a single availability zone experiences an outage.

### Remediation action:

1. Zone redundancy requires the **Standard** SKU or higher. Upgrade a Basic-tier Bastion to Standard before adding zones.
2. In the [Azure portal](https://portal.azure.com), navigate to your Bastion host, select **Configuration**, and upgrade the SKU to **Standard**.
3. Redeploy the Bastion host specifying multiple availability zones. Zone configuration must be set at creation time.
4. Ensure the associated public IP address uses a zone-redundant Standard SKU.
5. Verify that the `AzureBastionSubnet` has at least a `/26` address prefix to support the scaled deployment.

Using Azure CLI:
`az network bastion create --name <name> --resource-group <rg> --vnet-name <vnet> --public-ip-address <pip> --sku Standard --zones 1 2 3`

#### Related links

- [Azure Bastion overview](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)

<!--- Results --->

%TestResult%
