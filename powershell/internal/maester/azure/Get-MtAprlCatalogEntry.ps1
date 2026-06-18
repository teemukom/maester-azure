<#
.SYNOPSIS
    Returns an APRL catalog entry by GUID.

.DESCRIPTION
    Loads the bundled APRL catalog on first call (lazy init, cached for the session).
    The catalog maps APRL recommendation GUIDs to their metadata and ARG KQL queries.
    To refresh the catalog from the upstream APRL GitHub repo, run Update-MtAprlCatalog.

.PARAMETER AprlGuid
    The APRL recommendation GUID, e.g. 'c72b7fee-1fa0-5b4b-98e5-54bcae95bb74'.

.EXAMPLE
    Get-MtAprlCatalogEntry -AprlGuid 'c72b7fee-1fa0-5b4b-98e5-54bcae95bb74'

.LINK
    https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/
#>

$script:MtAprlCatalog = $null

function Get-MtAprlCatalogEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AprlGuid
    )

    if ($null -eq $script:MtAprlCatalog) {
        $script:MtAprlCatalog = @{

            # AZR.0001 — Azure Firewall: deploy across multiple availability zones
            'c72b7fee-1fa0-5b4b-98e5-54bcae95bb74' = @{
                AzrId        = 'AZR.0001'
                Title        = 'Deploy Azure Firewall across multiple availability zones'
                Impact       = 'High'
                ResourceType = 'Microsoft.Network/azureFirewalls'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/azureFirewalls/'
                Kql          = @'
resources
| where type == 'microsoft.network/azurefirewalls'
| where location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
| where array_length(zones) <= 1 or isnull(zones)
| where isempty(properties.virtualHub.id) or isnull(properties.virtualHub.id)
| project recommendationId = "c72b7fee-1fa0-5b4b-98e5-54bcae95bb74", name, id, tags, param1="multipleZones:false"
'@
            }

            # AZR.0002 — Virtual Machines: deploy across availability zones
            '2bd0be95-a825-6f47-a8c6-3db1fb5eb387' = @{
                AzrId        = 'AZR.0002'
                Title        = 'Deploy Virtual Machines across availability zones'
                Impact       = 'High'
                ResourceType = 'Microsoft.Compute/virtualMachines'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Compute/virtualMachines/'
                Kql          = @'
Resources
| where type =~ 'Microsoft.Compute/virtualMachines'
| where location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
| where isnull(zones)
| project recommendationId="2bd0be95-a825-6f47-a8c6-3db1fb5eb387", name, id, tags, param1="No Zone"
'@
            }

            # AZR.0003 — Load Balancer: ensure zone-redundant frontend
            '621dbc78-3745-4d32-8eac-9e65b27b7512' = @{
                AzrId        = 'AZR.0003'
                Title        = 'Ensure Standard Load Balancer is zone-redundant'
                Impact       = 'High'
                ResourceType = 'Microsoft.Network/loadBalancers'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/loadBalancers/'
                Kql          = @'
resources
| where type == "microsoft.network/loadbalancers"
| where location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
| where tolower(sku.name) != 'basic'
| mv-expand feIPconfigs = properties.frontendIPConfigurations
| extend feConfigName = (feIPconfigs.name), PrivateSubnetId = toupper(feIPconfigs.properties.subnet.id), PrivateIPZones = feIPconfigs.zones, PIPid = toupper(feIPconfigs.properties.publicIPAddress.id), JoinID = toupper(id)
| where isnotempty(PrivateSubnetId)
| where isnull(PrivateIPZones) or array_length(PrivateIPZones) < 2
| project name, feConfigName, id
| union (resources
    | where type == "microsoft.network/loadbalancers"
    | where location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
    | where tolower(sku.name) != 'basic'
    | mv-expand feIPconfigs = properties.frontendIPConfigurations
    | extend feConfigName = (feIPconfigs.name), PIPid = toupper(feIPconfigs.properties.publicIPAddress.id), JoinID = toupper(id)
    | where isnotempty(PIPid)
    | join kind=innerunique (
        resources
        | where type == "microsoft.network/publicipaddresses"
        | where location in~ ("centralindia", "centralus", "eastus", "japaneast", "japanwest", "newzealandnorth", "southcentralus", "southeastasia", "switzerlandnorth", "uaenorth", "westeurope", "westus3", "usgovvirginia", "chinanorth3")
        | where isnull(zones) or array_length(zones) < 2
        | extend LBid = toupper(substring(properties.ipConfiguration.id, 0, indexof(properties.ipConfiguration.id, '/frontendIPConfigurations'))), InnerID = toupper(id)
    ) on $left.PIPid == $right.InnerID)
| project recommendationId = "621dbc78-3745-4d32-8eac-9e65b27b7512", name, id, tags, param1="Zones: No Zone or Zonal", param2=strcat("Frontend IP Configuration:", " ", feConfigName)
'@
            }

            # AZR.0004 — Load Balancer: backend pool must have at least two instances
            '6d82d042-6d61-ad49-86f0-6a5455398081' = @{
                AzrId        = 'AZR.0004'
                Title        = 'Ensure the Load Balancer backend pool contains at least two instances'
                Impact       = 'High'
                ResourceType = 'Microsoft.Network/loadBalancers'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/loadBalancers/'
                Kql          = @'
resources
| where type =~ 'Microsoft.Network/loadBalancers'
| mv-expand bpool = properties.backendAddressPools
| extend BackendAddresses = array_length(bpool.properties.loadBalancerBackendAddresses)
| where BackendAddresses <= 1
| extend lbId = id, lbName = name, poolName = tostring(bpool.name), lbTags = tostring(tags)
| summarize impactedPools = make_list(poolName) by lbId, lbName, lbTags
| project recommendationId = "6d82d042-6d61-ad49-86f0-6a5455398081", name = lbName, id = lbId, tags = lbTags, param1 = strcat("backendPoolNames: ", strcat_array(impactedPools, ", "))
'@
            }

            # AZR.0005 — Public IP: use Standard SKU zone-redundant IPs
            'c63b81fb-7afc-894c-a840-91bb8a8dcfaf' = @{
                AzrId        = 'AZR.0005'
                Title        = 'Use Standard SKU and zone-redundant Public IP addresses when applicable'
                Impact       = 'High'
                ResourceType = 'Microsoft.Network/publicIPAddresses'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/publicIPAddresses/'
                Kql          = @'
resources
| where type =~ "Microsoft.Network/publicIPAddresses" and sku.tier =~ "Regional"
| where
    (location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
    and array_length(zones) <= 1)
    or
    (location in~ ("centralindia", "centralus", "eastus", "japaneast", "japanwest", "newzealandnorth", "southcentralus", "southeastasia", "switzerlandnorth", "uaenorth", "westeurope", "westus3", "usgovvirginia", "chinanorth3")
    and (isempty(zones) or array_length(zones) <= 1))
| extend az = case(isempty(zones), "Non-zonal", array_length(zones) <= 1, strcat("Zonal (", strcat_array(zones, ","), ")"), zones)
| project recommendationId = "c63b81fb-7afc-894c-a840-91bb8a8dcfaf", name, id, tags, param1 = strcat("sku: ", sku.name), param2 = strcat("availabilityZone: ", az)
'@
            }

            # AZR.0006 — Application Gateway: enable autoscale
            '823b0cff-05c0-2e4e-a1e7-9965e1cfa16f' = @{
                AzrId        = 'AZR.0006'
                Title        = 'Ensure Application Gateway autoscale is enabled with minimum capacity >= 2'
                Impact       = 'Medium'
                ResourceType = 'Microsoft.Network/applicationGateways'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/applicationGateways/'
                Kql          = @'
resources
| where type =~ "microsoft.network/applicationGateways"
| where isnull(properties.autoscaleConfiguration) or properties.autoscaleConfiguration.minCapacity <= 1
| project recommendationId = "823b0cff-05c0-2e4e-a1e7-9965e1cfa16f", name, id, tags, param1 = "autoScaleConfiguration: isNull or MinCapacity <= 1"
| order by id asc
'@
            }

            # AZR.0007 — Storage Accounts: use zone or region redundant SKU
            'e6c7e1cc-2f47-264d-aa50-1da421314472' = @{
                AzrId        = 'AZR.0007'
                Title        = 'Ensure storage accounts are zone or region redundant'
                Impact       = 'High'
                ResourceType = 'Microsoft.Storage/storageAccounts'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Storage/storageAccounts/'
                Kql          = @'
Resources
| where type =~ "Microsoft.Storage/storageAccounts"
| where sku.name in~ ("Standard_LRS", "Premium_LRS")
| project recommendationId = "e6c7e1cc-2f47-264d-aa50-1da421314472", name, id, tags, param1 = strcat("sku: ", sku.name)
'@
            }

            # AZR.0008 — Azure Cache for Redis: enable zone redundancy
            '5a44bd30-ae6a-4b81-9b68-dc3a8ffca4d8' = @{
                AzrId        = 'AZR.0008'
                Title        = 'Enable zone redundancy for Azure Cache for Redis'
                Impact       = 'High'
                ResourceType = 'Microsoft.Cache/Redis'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Cache/Redis/'
                Kql          = @'
resources
| where type =~ "microsoft.cache/redis"
| where location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
| where array_length(zones) <= 1 or isnull(zones)
| project recommendationId = "5a44bd30-ae6a-4b81-9b68-dc3a8ffca4d8", name, id, tags, param1 = "AvailabilityZones: Single Zone"
| order by id asc
'@
            }

            # AZR.0009 — Event Hub: ensure zone redundancy is enabled
            '84636c6c-b317-4722-b603-7b1ffc16384b' = @{
                AzrId        = 'AZR.0009'
                Title        = 'Ensure Event Hub namespace zone redundancy is enabled in supported regions'
                Impact       = 'High'
                ResourceType = 'Microsoft.EventHub/namespaces'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/EventHub/namespaces/'
                Kql          = @'
resources
| where type == "microsoft.eventhub/namespaces"
| where properties.zoneRedundant == false
| project recommendationId = "84636c6c-b317-4722-b603-7b1ffc16384b", name, id, tags, param1 = "ZoneRedundant: False"
| order by id asc
'@
            }

            # AZR.0010 — Key Vault: enable soft delete
            '1cca00d2-d9ab-8e42-a788-5d40f49405cb' = @{
                AzrId        = 'AZR.0010'
                Title        = 'Key vaults should have soft delete enabled'
                Impact       = 'High'
                ResourceType = 'Microsoft.KeyVault/vaults'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/KeyVault/vaults/'
                Kql          = @'
resources
| where type == "microsoft.keyvault/vaults"
| where isnull(properties.enableSoftDelete) or properties.enableSoftDelete != "true"
| project recommendationId = "1cca00d2-d9ab-8e42-a788-5d40f49405cb", name, id, tags, param1 = "EnableSoftDelete: Disabled"
'@
            }

            # AZR.0011 — Key Vault: enable purge protection
            '70fcfe6d-00e9-5544-a63a-fff42b9f2edb' = @{
                AzrId        = 'AZR.0011'
                Title        = 'Key vaults should have purge protection enabled'
                Impact       = 'Medium'
                ResourceType = 'Microsoft.KeyVault/vaults'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/KeyVault/vaults/'
                Kql          = @'
resources
| where type == "microsoft.keyvault/vaults"
| where isnull(properties.enablePurgeProtection) or properties.enablePurgeProtection != "true"
| project recommendationId = "70fcfe6d-00e9-5544-a63a-fff42b9f2edb", name, id, tags, param1 = "EnablePurgeProtection: Disabled"
'@
            }

            # AZR.0012 — Application Gateway: deploy in zone-redundant configuration
            'c9c00f2a-3888-714b-a72b-b4c9e8fcffb2' = @{
                AzrId        = 'AZR.0012'
                Title        = 'Deploy Application Gateway in a zone-redundant configuration'
                Impact       = 'High'
                ResourceType = 'Microsoft.Network/applicationGateways'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/applicationGateways/'
                Kql          = @'
resources
| where type =~ "microsoft.network/applicationGateways"
| where location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
| where isnull(zones) or array_length(zones) < 2
| extend zoneValue = iff((isnull(zones)), "null", zones)
| project recommendationId = "c9c00f2a-3888-714b-a72b-b4c9e8fcffb2", name, id, tags, param1="Zones: No Zone or Zonal", param2=strcat("Zones value: ", zoneValue)
'@
            }

            # AZR.0013 — VPN Gateway: choose a zone-redundant SKU
            '5b1933a6-90e4-f642-a01f-e58594e5aab2' = @{
                AzrId        = 'AZR.0013'
                Title        = 'Choose a zone-redundant VPN gateway SKU'
                Impact       = 'High'
                ResourceType = 'Microsoft.Network/virtualNetworkGateways'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/virtualNetworkGateways/'
                Kql          = @'
resources
| where type =~ "Microsoft.Network/virtualNetworkGateways"
| where location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
| where properties.gatewayType == "Vpn"
| where properties.sku.tier !contains 'AZ'
| project recommendationId = "5b1933a6-90e4-f642-a01f-e58594e5aab2", name, id, tags, param1= strcat("sku-tier: " , properties.sku.tier), param2=location
| order by id asc
'@
            }

            # AZR.0014 — Azure Bastion: deploy with availability zones
            # HasAutomation: false — APRL has no ARG query for this recommendation
            'bastion-az-manual' = @{
                AzrId        = 'AZR.0014'
                Title        = 'Deploy Azure Bastion with availability zones'
                Impact       = 'High'
                ResourceType = 'Microsoft.Network/bastionHosts'
                HasAutomation = $false
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/bastionHosts/'
                Kql          = $null
            }

            # AZR.0015 — Recovery Services Vault: enable soft delete
            '9e39919b-78af-4a0b-b70f-c548dae97c25' = @{
                AzrId        = 'AZR.0015'
                Title        = 'Enable Soft Delete for Recovery Services Vaults in Azure Backup'
                Impact       = 'Medium'
                ResourceType = 'Microsoft.RecoveryServices/vaults'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/RecoveryServices/vaults/'
                Kql          = @'
resources
| where type == "microsoft.recoveryservices/vaults"
| mv-expand issoftDelete=properties.securitySettings.softDeleteSettings.softDeleteState
| where issoftDelete == 'Disabled'
| project recommendationId = "9e39919b-78af-4a0b-b70f-c548dae97c25", name, id, tags, param1=strcat("Soft Delete: ",issoftDelete)
'@
            }

            # AZR.0016 — Cosmos DB: configure at least two regions
            '43663217-a1d3-844b-80ea-571a2ce37c6c' = @{
                AzrId        = 'AZR.0016'
                Title        = 'Configure Cosmos DB accounts with at least two regions for high availability'
                Impact       = 'High'
                ResourceType = 'Microsoft.DocumentDB/databaseAccounts'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/DocumentDB/databaseAccounts/'
                Kql          = @'
Resources
| where type =~ 'Microsoft.DocumentDb/databaseAccounts'
| where
    array_length(properties.locations) < 2 or
    (array_length(properties.locations) < 3 and properties.consistencyPolicy.defaultConsistencyLevel == 'Strong')
| project recommendationId='43663217-a1d3-844b-80ea-571a2ce37c6c', name, id, tags
'@
            }

            # AZR.0017 — Cosmos DB: enable service-managed failover for multi-region accounts
            '9cabded7-a1fc-6e4a-944b-d7dd98ea31a2' = @{
                AzrId        = 'AZR.0017'
                Title        = 'Enable service-managed failover for multi-region Cosmos DB accounts with single write region'
                Impact       = 'High'
                ResourceType = 'Microsoft.DocumentDB/databaseAccounts'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/DocumentDB/databaseAccounts/'
                Kql          = @'
Resources
| where type =~ 'Microsoft.DocumentDb/databaseAccounts'
| where
    array_length(properties.locations) > 1 and
    tobool(properties.enableAutomaticFailover) == false and
    tobool(properties.enableMultipleWriteLocations) == false
| project recommendationId='9cabded7-a1fc-6e4a-944b-d7dd98ea31a2', name, id, tags
'@
            }

            # AZR.0018 — AKS: deploy cluster node pools across availability zones
            '4f63619f-5001-439c-bacb-8de891287727' = @{
                AzrId        = 'AZR.0018'
                Title        = 'Deploy AKS cluster node pools across availability zones'
                Impact       = 'High'
                ResourceType = 'Microsoft.ContainerService/managedClusters'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/ContainerService/managedClusters/'
                Kql          = @'
resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
| project id, name, tags, location, pools = properties.agentPoolProfiles
| mv-expand pool = pools
| extend numOfAvailabilityZones = iif(isnull(pool.availabilityZones), 0, array_length(pool.availabilityZones))
| where numOfAvailabilityZones < 2
| project
    recommendationId = "4f63619f-5001-439c-bacb-8de891287727",
    name=pool.name,
    id=strcat(id,"/agentPools/",pool.name),
    tags,
    param1 = strcat("NodePoolName: ", pool.name),
    param2 = strcat("Mode: ", pool.mode),
    param3 = strcat("AvailabilityZones: ", iif(numOfAvailabilityZones == 0, "None", strcat("Zone ", strcat_array(pool.availabilityZones, ", ")))),
    param4 = strcat("Location: ", location)
'@
            }

            # AZR.0019 — VPN Gateway: enable Active-Active mode
            '281a2713-c0e0-3c48-b596-19f590c46671' = @{
                AzrId        = 'AZR.0019'
                Title        = 'Enable Active-Active VPN Gateways for redundancy'
                Impact       = 'Medium'
                ResourceType = 'Microsoft.Network/virtualNetworkGateways'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/virtualNetworkGateways/'
                Kql          = @'
resources
| where type =~ 'Microsoft.Network/virtualNetworkGateways'
| where properties.gatewayType =~ "vpn"
| extend gatewayType = properties.gatewayType, vpnType = properties.vpnType, connections = properties.connections, activeactive=properties.activeActive
| where activeactive == false
| project recommendationId = "281a2713-c0e0-3c48-b596-19f590c46671", name, id, tags
'@
            }

            # AZR.0020 — Load Balancer: use Standard SKU
            '38c3bca1-97a1-eb42-8cd3-838b243f35ba' = @{
                AzrId        = 'AZR.0020'
                Title        = 'Use Standard Load Balancer SKU'
                Impact       = 'High'
                ResourceType = 'Microsoft.Network/loadBalancers'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/loadBalancers/'
                Kql          = @'
resources
| where type =~ 'Microsoft.Network/loadBalancers'
| where sku.name == 'Basic'
| project recommendationId = "38c3bca1-97a1-eb42-8cd3-838b243f35ba", name, id, tags, Param1=strcat("sku-tier: basic")
'@
            }

            # AZR.0021 — Application Gateway: migrate to v2
            '7893f0b3-8622-1d47-beed-4b50a19f7895' = @{
                AzrId        = 'AZR.0021'
                Title        = 'Migrate to Application Gateway v2'
                Impact       = 'High'
                ResourceType = 'Microsoft.Network/applicationGateways'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/applicationGateways/'
                Kql          = @'
resources
| where type =~ 'microsoft.network/applicationgateways'
| extend tier = properties.sku.tier
| where tier == 'Standard' or tier == 'WAF'
| project recommendationId = "7893f0b3-8622-1d47-beed-4b50a19f7895", name, id, tags
'@
            }

            # AZR.0022 — Application Gateway: use health probes
            '847a8d88-21c4-bc48-a94e-562206edd767' = @{
                AzrId        = 'AZR.0022'
                Title        = 'Use Health Probes to detect Application Gateway backend availability'
                Impact       = 'High'
                ResourceType = 'Microsoft.Network/applicationGateways'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/applicationGateways/'
                Kql          = @'
resources
| where type =~ "microsoft.network/applicationGateways"
| where array_length(properties.probes) == 0
| project recommendationId="847a8d88-21c4-bc48-a94e-562206edd767", name, id, tags, param1="customHealthProbeUsed: false"
'@
            }

            # AZR.0023 — Public IP: upgrade Basic SKU to Standard
            '5cea1501-6fe4-4ec4-ac8f-f72320eb18d3' = @{
                AzrId        = 'AZR.0023'
                Title        = 'Upgrade Basic SKU public IP addresses to Standard SKU'
                Impact       = 'Medium'
                ResourceType = 'Microsoft.Network/publicIPAddresses'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/publicIPAddresses/'
                Kql          = @'
Resources
| where type =~ "Microsoft.Network/publicIPAddresses"
| where sku.name =~ "Basic"
| project recommendationId = "5cea1501-6fe4-4ec4-ac8f-f72320eb18d3", name, id, tags, param1 = strcat("sku: ", sku.name)
'@
            }

            # AZR.0024 — SQL Database: use Active Geo Replication
            '74c2491d-048b-0041-a140-935960220e20' = @{
                AzrId        = 'AZR.0024'
                Title        = 'Use Active Geo Replication to create a readable secondary in another region'
                Impact       = 'High'
                ResourceType = 'Microsoft.Sql/servers/databases'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Sql/servers/'
                Kql          = @'
resources
| where type == "microsoft.sql/servers/databases" and name != "master"
| summarize secondaryTypeCount = countif(isnotempty(properties.secondaryType)) by name
| where secondaryTypeCount == 0
| join kind=inner (
    resources
    | where type == "microsoft.sql/servers/databases" and name != "master"
) on name
| extend param1 = "Not part of Geo Replication"
| project recommendationId = "74c2491d-048b-0041-a140-935960220e20", name, id, tags, param1
'@
            }

            # AZR.0025 — SQL Database: configure Auto Failover Groups
            '943c168a-2ec2-a94c-8015-85732a1b4859' = @{
                AzrId        = 'AZR.0025'
                Title        = 'Configure Auto Failover Groups for SQL databases'
                Impact       = 'High'
                ResourceType = 'Microsoft.Sql/servers/databases'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Sql/servers/'
                Kql          = @'
resources
| where type =~'microsoft.sql/servers/databases' and name !~ "master"
| where isnull(properties['failoverGroupId'])
| project recommendationId = "943c168a-2ec2-a94c-8015-85732a1b4859", name, id, tags, param1= strcat("databaseId=", properties['databaseId'])
'@
            }

            # AZR.0026 — SQL Database: enable zone redundancy
            'c0085c32-84c0-c247-bfa9-e70977cbf108' = @{
                AzrId        = 'AZR.0026'
                Title        = 'Enable zone redundancy for Azure SQL Database'
                Impact       = 'High'
                ResourceType = 'Microsoft.Sql/servers/databases'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Sql/servers/'
                Kql          = @'
Resources
| where type =~ 'microsoft.sql/servers/databases'
| where location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
| where tolower(tostring(properties.zoneRedundant))=~'false'
| project recommendationId = "c0085c32-84c0-c247-bfa9-e70977cbf108", name, id, tags
'@
            }

            # AZR.0027 — Service Bus: enforce minimum TLS 1.2
            'f075a1bd-de9e-4819-9a1d-1ac41037a74f' = @{
                AzrId        = 'AZR.0027'
                Title        = 'Configure the minimum TLS version for Service Bus namespaces to TLS v1.2 or higher'
                Impact       = 'High'
                ResourceType = 'Microsoft.ServiceBus/namespaces'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/ServiceBus/namespaces/'
                Kql          = @'
resources
| where type =~ "Microsoft.ServiceBus/namespaces"
| where properties.minimumTlsVersion in ("1.0", "1.1")
| project
    recommendationId = "f075a1bd-de9e-4819-9a1d-1ac41037a74f",
    name,
    id,
    tags,
    param1 = strcat("minimumTlsVersion: ", properties.minimumTlsVersion)
'@
            }

            # AZR.0028 — API Management: migrate to Premium SKU
            'baf3bfc0-32a2-4c0c-926d-c9bf0b49808e' = @{
                AzrId        = 'AZR.0028'
                Title        = 'Migrate API Management services to Premium SKU to support Availability Zones'
                Impact       = 'High'
                ResourceType = 'Microsoft.ApiManagement/service'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/ApiManagement/service/'
                Kql          = @'
resources
| where type =~ 'Microsoft.ApiManagement/service'
| extend skuName = sku.name
| where tolower(skuName) != tolower('premium')
| project recommendationId = "baf3bfc0-32a2-4c0c-926d-c9bf0b49808e", name, id, tags, param1=strcat("SKU: ", skuName)
'@
            }

            # AZR.0029 — API Management: enable Availability Zones (Premium only)
            '740f2c1c-8857-4648-80eb-47d2c56d5a50' = @{
                AzrId        = 'AZR.0029'
                Title        = 'Enable Availability Zones on Premium API Management instances'
                Impact       = 'High'
                ResourceType = 'Microsoft.ApiManagement/service'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/ApiManagement/service/'
                Kql          = @'
resources
| where type =~ 'Microsoft.ApiManagement/service'
| where location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
| extend skuName = sku.name
| where tolower(skuName) == tolower('premium')
| where isnull(zones) or array_length(zones) < 2
| extend zoneValue = iff((isnull(zones)), "null", zones)
| project recommendationId = "740f2c1c-8857-4648-80eb-47d2c56d5a50", name, id, tags, param1="Zones: No Zone or Zonal", param2=strcat("Zones value: ", zoneValue)
'@
            }

            # AZR.0030 — API Management: upgrade to stv2 platform
            'e35cf148-8eee-49d1-a1c9-956160f99e0b' = @{
                AzrId        = 'AZR.0030'
                Title        = 'Azure API Management platform version should be stv2'
                Impact       = 'High'
                ResourceType = 'Microsoft.ApiManagement/service'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/ApiManagement/service/'
                Kql          = @'
resources
| where type =~ 'Microsoft.ApiManagement/service'
| extend plat_version = properties.platformVersion
| extend skuName = sku.name
| where tolower(plat_version) == tolower('stv1')
| project recommendationId = "e35cf148-8eee-49d1-a1c9-956160f99e0b", name, id, tags, param1=strcat("Platform Version: ", plat_version), param2=strcat("SKU: ", skuName)
'@
            }

            # AZR.0031 — VNet: ensure all subnets have an NSG
            'f0bf9ae6-25a5-974d-87d5-025abec73539' = @{
                AzrId        = 'AZR.0031'
                Title        = 'All Subnets should have a Network Security Group associated'
                Impact       = 'Low'
                ResourceType = 'Microsoft.Network/virtualNetworks'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/virtualNetworks/'
                Kql          = @'
resources
| where type =~ 'Microsoft.Network/virtualnetworks'
| mv-expand subnets = properties.subnets
| extend sn = string_size(subnets.properties.networkSecurityGroup)
| where sn == 0 and subnets.name !in ("GatewaySubnet", "AzureFirewallSubnet", "AzureFirewallManagementSubnet", "RouteServerSubnet")
| project recommendationId = "f0bf9ae6-25a5-974d-87d5-025abec73539", name, id, tags, param1 = strcat("SubnetName: ", subnets.name), param2 = "NSG: False"
'@
            }

            # AZR.0032 — VNet: enable DDoS Protection
            '69ea1185-19b7-de40-9da1-9e8493547a5c' = @{
                AzrId        = 'AZR.0032'
                Title        = 'Shield public endpoints in Azure VNets with Azure DDoS Standard Protection Plans'
                Impact       = 'High'
                ResourceType = 'Microsoft.Network/virtualNetworks'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/virtualNetworks/'
                Kql          = @'
resources
| where type =~ 'Microsoft.Network/virtualNetworks'
| where isnull(properties.enableDdosProtection) or properties.enableDdosProtection contains "false"
| project recommendationId = "69ea1185-19b7-de40-9da1-9e8493547a5c", name, id, tags, param1 = strcat("EnableDdosProtection: ", properties.enableDdosProtection)
'@
            }

            # AZR.0033 — VNet: use Private Endpoints instead of Service Endpoints
            '24ae3773-cc2c-3649-88de-c9788e25b463' = @{
                AzrId        = 'AZR.0033'
                Title        = 'When available, use Private Endpoints instead of Service Endpoints for PaaS services'
                Impact       = 'Medium'
                ResourceType = 'Microsoft.Network/virtualNetworks'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/virtualNetworks/'
                Kql          = @'
resources
| where type =~ 'Microsoft.Network/virtualnetworks'
| mv-expand subnets = properties.subnets
| extend se = array_length(subnets.properties.serviceEndpoints)
| where se >= 1
| project name, id, tags, subnets, serviceEndpoints=todynamic(subnets.properties.serviceEndpoints)
| mv-expand serviceEndpoints
| project name, id, tags, subnetName=subnets.name, serviceName=tostring(serviceEndpoints.service)
| where serviceName in (parse_json('["Microsoft.CognitiveServices","Microsoft.AzureCosmosDB","Microsoft.DBforMariaDB","Microsoft.DBforMySQL","Microsoft.DBforPostgreSQL","Microsoft.EventHub","Microsoft.KeyVault","Microsoft.ServiceBus","Microsoft.Sql","Microsoft.Storage","Microsoft.StorageSync","Microsoft.Synapse","Microsoft.Web"]'))
| project recommendationId = "24ae3773-cc2c-3649-88de-c9788e25b463", name, id, tags, param1 = strcat("subnet=", subnetName), param2=strcat("serviceName=",serviceName), param3="ServiceEndpoints=true"
'@
            }

            # AZR.0034 — VNet: enable Flow Logs
            '06b77be9-56a3-4d41-b362-8b295c5a283d' = @{
                AzrId        = 'AZR.0034'
                Title        = 'Enable Virtual Network Flow Logs'
                Impact       = 'Medium'
                ResourceType = 'Microsoft.Network/virtualNetworks'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Network/virtualNetworks/'
                Kql          = @'
resources
| where type =~ "Microsoft.Network/virtualNetworks"
| extend vnetId = tolower(tostring(id)), vnetName = name, vnetTags = tags, vnetLocation = location
| join kind = leftouter (
    resources
    | where type =~ "microsoft.network/networkwatchers/flowlogs"
    | extend flowLogType = iff(
        properties.targetResourceId contains "Microsoft.Network/virtualNetworks",
        'Virtual network',
        'Virtual network'
      )
    | extend flowLogTargetVnet = tolower(properties.targetResourceId)
) on $left.vnetId == $right.flowLogTargetVnet
| where strlen(flowLogTargetVnet) == 0
| project recommendationId = "06b77be9-56a3-4d41-b362-8b295c5a283d", name=vnetName, id=vnetId, tags, param1 = "Missing Vnet Flow Log configuration"
'@
            }

            # AZR.0035 — App Service (sites): deploy to a staging slot
            'a1d91661-32d4-430b-b3b6-5adeb0975df7' = @{
                AzrId        = 'AZR.0035'
                Title        = 'Deploy App Service to a staging slot'
                Impact       = 'Low'
                ResourceType = 'Microsoft.Web/sites'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Web/sites/'
                Kql          = @'
resources
| where type =~ 'microsoft.web/sites' or type =~ 'microsoft.web/sites/slots'
| extend Sku = tostring(properties.sku)
| where tolower(Sku) contains "standard" or tolower(Sku) contains "premium" or tolower(Sku) contains "isolatedv2"
| summarize count() by repositorySiteName = tostring(properties.repositorySiteName)
| where count_ == 1
| join kind=inner (
    resources
    | where type =~ 'microsoft.web/sites'
    | extend repositorySiteName = tostring(properties.repositorySiteName)
    | extend Sku = tostring(properties.sku)
    | project id, name, subscriptionId, repositorySiteName, Sku
) on repositorySiteName
| project recommendationId="a1d91661-32d4-430b-b3b6-5adeb0975df7", name, id, tags="", param1=Sku, param2="DeploymentSlotEnabled=false"
'@
            }

            # AZR.0036 — App Service Plan (serverFarms): migrate to availability zone support
            '88cb90c2-3b99-814b-9820-821a63f600dd' = @{
                AzrId        = 'AZR.0036'
                Title        = 'Migrate App Service Plan to availability zone support'
                Impact       = 'High'
                ResourceType = 'Microsoft.Web/serverFarms'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Web/serverFarms/'
                Kql          = @'
resources
| where type =~ 'microsoft.web/serverfarms'
| where location in~ ("australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus", "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral", "israelcentral", "italynorth", "japaneast", "japanwest", "koreacentral", "mexicocentral", "newzealandnorth", "northeurope", "norwayeast", "polandcentral", "qatarcentral", "southafricanorth", "southcentralus", "southeastasia", "spaincentral", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth", "westeurope", "westus2", "westus3", "usgovvirginia", "chinanorth3")
| extend zoneRedundant = tobool(properties.zoneRedundant)
| extend sku_tier = tostring(sku.tier)
| where (tolower(sku_tier) contains "isolated" or tolower(sku_tier) contains "premium") and zoneRedundant == false
| project recommendationId="88cb90c2-3b99-814b-9820-821a63f600dd", name, id, tags, param1=sku_tier, param2="Not Zone Redundant"
'@
            }

            # AZR.0037 — App Service Plan (serverFarms): use Standard or Premium tier
            'b2113023-a553-2e41-9789-597e2fb54c31' = @{
                AzrId        = 'AZR.0037'
                Title        = 'Use Standard or Premium tier for App Service Plans'
                Impact       = 'High'
                ResourceType = 'Microsoft.Web/serverFarms'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Web/serverFarms/'
                Kql          = @'
resources
| where type =~ 'microsoft.web/serverfarms'
| extend sku_tier = tostring(sku.tier)
| where tolower(sku_tier) !contains "standard" and
        tolower(sku_tier) !contains "premium" and
        tolower(sku_tier) !contains "isolatedv2"
| project recommendationId="b2113023-a553-2e41-9789-597e2fb54c31", name, id, tags, param1=strcat("SKU=",sku_tier)
'@
            }

            # AZR.0038 — App Service Plan (serverFarms): set minimum instance count to 2
            '855ca19a-6518-4f2e-9e5a-01796fbca9f8' = @{
                AzrId        = 'AZR.0038'
                Title        = 'Set minimum instance count to 2 for App Service Plans'
                Impact       = 'High'
                ResourceType = 'Microsoft.Web/serverFarms'
                HasAutomation = $true
                LearnMoreUrl = 'https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/Web/serverFarms/'
                Kql          = @'
resources
| where type == "microsoft.web/serverfarms"
| where sku.capacity < 2
| project recommendationId="855ca19a-6518-4f2e-9e5a-01796fbca9f8", name, id, tags, param1="Instance count is less than 2"
'@
            }

        } # end $script:MtAprlCatalog
    }

    return $script:MtAprlCatalog[$AprlGuid]
}
