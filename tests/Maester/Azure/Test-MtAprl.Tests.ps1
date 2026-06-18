Describe "AzureConfig" -Tag "Azure", "APRL", "Reliability", "Resiliency" {

    It "AZR.0001: Deploy Azure Firewall across multiple availability zones" -Tag "AZR.0001", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid 'c72b7fee-1fa0-5b4b-98e5-54bcae95bb74'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Azure Firewalls should be deployed across multiple availability zones"
        }
    }

    It "AZR.0002: Deploy Virtual Machines across availability zones" -Tag "AZR.0002", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '2bd0be95-a825-6f47-a8c6-3db1fb5eb387'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Virtual Machines should be assigned to an availability zone"
        }
    }

    It "AZR.0003: Ensure Standard Load Balancer is zone-redundant" -Tag "AZR.0003", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '621dbc78-3745-4d32-8eac-9e65b27b7512'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Standard Load Balancers should have zone-redundant frontend IP configurations"
        }
    }

    It "AZR.0004: Ensure Load Balancer backend pool contains at least two instances" -Tag "AZR.0004", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '6d82d042-6d61-ad49-86f0-6a5455398081'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Load Balancer backend pools should have at least two instances for redundancy"
        }
    }

    It "AZR.0005: Use Standard SKU and zone-redundant Public IP addresses" -Tag "AZR.0005", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid 'c63b81fb-7afc-894c-a840-91bb8a8dcfaf'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Public IP addresses should be Standard SKU and zone-redundant"
        }
    }

    It "AZR.0006: Ensure Application Gateway autoscale is enabled with minimum capacity >= 2" -Tag "AZR.0006", "Severity:Medium" {
        $Result = Test-MtAprlRecommendation -AprlGuid '823b0cff-05c0-2e4e-a1e7-9965e1cfa16f'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Application Gateways should have autoscale enabled with a minimum capacity of at least 2"
        }
    }

    It "AZR.0007: Ensure storage accounts are zone or region redundant" -Tag "AZR.0007", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid 'e6c7e1cc-2f47-264d-aa50-1da421314472'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Storage accounts should use ZRS, GRS, GZRS, or RA-GRS — not LRS or Premium_LRS"
        }
    }

    It "AZR.0008: Enable zone redundancy for Azure Cache for Redis" -Tag "AZR.0008", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '5a44bd30-ae6a-4b81-9b68-dc3a8ffca4d8'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Azure Cache for Redis should be configured with zone redundancy"
        }
    }

    It "AZR.0009: Ensure Event Hub namespace zone redundancy is enabled" -Tag "AZR.0009", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '84636c6c-b317-4722-b603-7b1ffc16384b'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Event Hub namespaces should have zone redundancy enabled"
        }
    }

    It "AZR.0010: Key vaults should have soft delete enabled" -Tag "AZR.0010", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '1cca00d2-d9ab-8e42-a788-5d40f49405cb'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Key Vault soft delete protects against accidental or malicious deletion"
        }
    }

    It "AZR.0011: Key vaults should have purge protection enabled" -Tag "AZR.0011", "Severity:Medium" {
        $Result = Test-MtAprlRecommendation -AprlGuid '70fcfe6d-00e9-5544-a63a-fff42b9f2edb'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Key Vault purge protection prevents permanent deletion during the soft delete retention period"
        }
    }

    It "AZR.0012: Deploy Application Gateway in a zone-redundant configuration" -Tag "AZR.0012", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid 'c9c00f2a-3888-714b-a72b-b4c9e8fcffb2'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Application Gateways should be deployed across at least two availability zones"
        }
    }

    It "AZR.0013: Choose a zone-redundant VPN gateway SKU" -Tag "AZR.0013", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '5b1933a6-90e4-f642-a01f-e58594e5aab2'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "VPN Gateways in AZ-capable regions should use a zone-redundant SKU (e.g. VpnGw1AZ)"
        }
    }

    It "AZR.0015: Enable Soft Delete for Recovery Services Vaults" -Tag "AZR.0015", "Severity:Medium" {
        $Result = Test-MtAprlRecommendation -AprlGuid '9e39919b-78af-4a0b-b70f-c548dae97c25'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Recovery Services Vault soft delete protects backup data against accidental deletion"
        }
    }

    It "AZR.0016: Configure Cosmos DB accounts with at least two regions" -Tag "AZR.0016", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '43663217-a1d3-844b-80ea-571a2ce37c6c'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Cosmos DB accounts should have at least two read regions to ensure availability during regional failures"
        }
    }

    It "AZR.0017: Enable service-managed failover for multi-region Cosmos DB accounts" -Tag "AZR.0017", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '9cabded7-a1fc-6e4a-944b-d7dd98ea31a2'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Multi-region Cosmos DB accounts should have automatic failover or multi-write enabled"
        }
    }

    It "AZR.0018: Deploy AKS cluster node pools across availability zones" -Tag "AZR.0018", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '4f63619f-5001-439c-bacb-8de891287727'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "AKS node pools should span at least two availability zones to tolerate zone failure"
        }
    }

    It "AZR.0019: Enable Active-Active mode for VPN Gateways" -Tag "AZR.0019", "Severity:Medium" {
        $Result = Test-MtAprlRecommendation -AprlGuid '281a2713-c0e0-3c48-b596-19f590c46671'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "VPN Gateways should use Active-Active mode to avoid single points of failure"
        }
    }

    It "AZR.0020: Use Standard Load Balancer SKU" -Tag "AZR.0020", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '38c3bca1-97a1-eb42-8cd3-838b243f35ba'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Basic SKU Load Balancers do not support availability zones or SLA guarantees"
        }
    }

    It "AZR.0021: Migrate to Application Gateway v2" -Tag "AZR.0021", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '7893f0b3-8622-1d47-beed-4b50a19f7895'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Application Gateway v1 SKU is deprecated and does not support availability zones"
        }
    }

    It "AZR.0022: Use Health Probes to detect Application Gateway backend availability" -Tag "AZR.0022", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '847a8d88-21c4-bc48-a94e-562206edd767'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Application Gateways should use health probes to detect and route around unhealthy backends"
        }
    }

    It "AZR.0023: Upgrade Basic SKU Public IP addresses to Standard SKU" -Tag "AZR.0023", "Severity:Medium" {
        $Result = Test-MtAprlRecommendation -AprlGuid '5cea1501-6fe4-4ec4-ac8f-f72320eb18d3'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Basic SKU Public IP addresses do not support availability zones and have a different SLA than Standard SKU"
        }
    }

    It "AZR.0024: Use Active Geo Replication for Azure SQL databases" -Tag "AZR.0024", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '74c2491d-048b-0041-a140-935960220e20'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "SQL databases should use Active Geo Replication to create a readable secondary in another region"
        }
    }

    It "AZR.0025: Configure Auto Failover Groups for Azure SQL databases" -Tag "AZR.0025", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '943c168a-2ec2-a94c-8015-85732a1b4859'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "SQL databases should belong to an Auto Failover Group to enable automatic regional failover"
        }
    }

    It "AZR.0026: Enable zone redundancy for Azure SQL Database" -Tag "AZR.0026", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid 'c0085c32-84c0-c247-bfa9-e70977cbf108'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "SQL databases in AZ-capable regions should be configured as zone-redundant"
        }
    }

    It "AZR.0028: Migrate API Management services to Premium SKU to support Availability Zones" -Tag "AZR.0028", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid 'baf3bfc0-32a2-4c0c-926d-c9bf0b49808e'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Only Premium SKU API Management instances support Availability Zones"
        }
    }

    It "AZR.0029: Enable Availability Zones on Premium API Management instances" -Tag "AZR.0029", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '740f2c1c-8857-4648-80eb-47d2c56d5a50'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Premium API Management instances in AZ-capable regions should be deployed across at least two availability zones"
        }
    }

    It "AZR.0030: Upgrade API Management platform version to stv2" -Tag "AZR.0030", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid 'e35cf148-8eee-49d1-a1c9-956160f99e0b'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "API Management stv1 platform is deprecated — stv2 offers improved reliability and zone redundancy support"
        }
    }

    It "AZR.0032: Enable DDoS Protection for Virtual Networks" -Tag "AZR.0032", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '69ea1185-19b7-de40-9da1-9e8493547a5c'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "VNets with public-facing endpoints should be protected by Azure DDoS Standard"
        }
    }

    It "AZR.0035: Deploy App Service to a staging slot" -Tag "AZR.0035", "Severity:Low" {
        $Result = Test-MtAprlRecommendation -AprlGuid 'a1d91661-32d4-430b-b3b6-5adeb0975df7'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "App Services on Standard/Premium/IsolatedV2 plans should use deployment slots for zero-downtime deployments"
        }
    }

    It "AZR.0036: Migrate App Service Plan to availability zone support" -Tag "AZR.0036", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '88cb90c2-3b99-814b-9820-821a63f600dd'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Isolated and Premium App Service Plans in AZ-capable regions should be zone redundant"
        }
    }

    It "AZR.0037: Use Standard or Premium tier for App Service Plans" -Tag "AZR.0037", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid 'b2113023-a553-2e41-9789-597e2fb54c31'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "App Service Plans should use Standard, Premium, or IsolatedV2 tier for SLA, scaling, and AZ support"
        }
    }

    It "AZR.0038: Set minimum instance count to 2 for App Service Plans" -Tag "AZR.0038", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid '855ca19a-6518-4f2e-9e5a-01796fbca9f8'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "App Service Plans should have at least two instances to tolerate single-instance failures"
        }
    }

}

Describe "AzureConfig" -Tag "Azure", "APRL", "Security" {

    It "AZR.0027: Configure Service Bus minimum TLS version to 1.2 or higher" -Tag "AZR.0027", "Severity:High" {
        $Result = Test-MtAprlRecommendation -AprlGuid 'f075a1bd-de9e-4819-9a1d-1ac41037a74f'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Service Bus namespaces should enforce TLS 1.2 as the minimum version"
        }
    }

    It "AZR.0031: Ensure all subnets have a Network Security Group associated" -Tag "AZR.0031", "Severity:Low" {
        $Result = Test-MtAprlRecommendation -AprlGuid 'f0bf9ae6-25a5-974d-87d5-025abec73539'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "All subnets (except gateway and firewall subnets) should have an NSG to control traffic flow"
        }
    }

    It "AZR.0033: Use Private Endpoints instead of Service Endpoints for PaaS services" -Tag "AZR.0033", "Severity:Medium" {
        $Result = Test-MtAprlRecommendation -AprlGuid '24ae3773-cc2c-3649-88de-c9788e25b463'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "Service Endpoints expose a broader attack surface than Private Endpoints for services that support Private Link"
        }
    }

}

Describe "AzureConfig" -Tag "Azure", "APRL", "OperationalExcellence" {

    It "AZR.0034: Enable Virtual Network Flow Logs" -Tag "AZR.0034", "Severity:Medium" {
        $Result = Test-MtAprlRecommendation -AprlGuid '06b77be9-56a3-4d41-b362-8b295c5a283d'
        if ($null -ne $Result) {
            $Result | Should -Be $true -Because "VNet Flow Logs provide visibility into network traffic for troubleshooting and security analysis"
        }
    }

}
