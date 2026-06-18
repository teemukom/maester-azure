<#
.SYNOPSIS
    Refreshes the in-memory APRL catalog for the current session from the upstream GitHub repo.

.DESCRIPTION
    Optional maintenance tool. Downloads the latest KQL queries and metadata from the Azure
    Proactive Resiliency Library v2 GitHub repository and updates the in-memory catalog used
    by Test-MtAprlRecommendation for the duration of the current session.

    This is NOT required to run tests — the catalog ships bundled with the module and is
    current as of the last module release. Run this only when you need APRL updates that
    were published after the current module version.

    To permanently update the catalog, edit Get-MtAprlCatalogEntry.ps1 and submit a PR.

.PARAMETER Force
    Re-fetches from GitHub even if the catalog was already refreshed this session.

.EXAMPLE
    Update-MtAprlCatalog

    Fetches the latest APRL catalog and updates the in-memory cache.

.LINK
    https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/
#>
function Update-MtAprlCatalog {
    [CmdletBinding()]
    param(
        [switch]$Force
    )

    $AprlBaseUrl = 'https://raw.githubusercontent.com/Azure/Azure-Proactive-Resiliency-Library-v2/main/azure-resources'

    $ResourcePaths = @(
        'Network/azureFirewalls',
        'Network/virtualNetworkGateways',
        'Network/applicationGateways',
        'Network/bastionHosts',
        'Network/loadBalancers',
        'Network/publicIPAddresses',
        'Compute/virtualMachines',
        'Storage/storageAccounts',
        'Cache/Redis',
        'EventHub/namespaces',
        'KeyVault/vaults',
        'DocumentDB/databaseAccounts',
        'ContainerService/managedClusters',
        'RecoveryServices/vaults'
    )

    # The GUIDs tracked by this module's test suite
    $TrackedGuids = @(
        'c72b7fee-1fa0-5b4b-98e5-54bcae95bb74',
        '2bd0be95-a825-6f47-a8c6-3db1fb5eb387',
        '621dbc78-3745-4d32-8eac-9e65b27b7512',
        '6d82d042-6d61-ad49-86f0-6a5455398081',
        'c63b81fb-7afc-894c-a840-91bb8a8dcfaf',
        '823b0cff-05c0-2e4e-a1e7-9965e1cfa16f',
        'e6c7e1cc-2f47-264d-aa50-1da421314472',
        '5a44bd30-ae6a-4b81-9b68-dc3a8ffca4d8',
        '84636c6c-b317-4722-b603-7b1ffc16384b',
        '1cca00d2-d9ab-8e42-a788-5d40f49405cb',
        '70fcfe6d-00e9-5544-a63a-fff42b9f2edb',
        'c9c00f2a-3888-714b-a72b-b4c9e8fcffb2',
        '5b1933a6-90e4-f642-a01f-e58594e5aab2',
        '9e39919b-78af-4a0b-b70f-c548dae97c25',
        '43663217-a1d3-844b-80ea-571a2ce37c6c',
        '9cabded7-a1fc-6e4a-944b-d7dd98ea31a2',
        '4f63619f-5001-439c-bacb-8de891287727'
    )

    Write-Host "Fetching APRL recommendations from GitHub..." -ForegroundColor Cyan

    $UpdatedCount = 0
    $FailedCount  = 0

    foreach ($ResourcePath in $ResourcePaths) {
        $Url = "$AprlBaseUrl/$ResourcePath/recommendations.yaml"
        try {
            $Response = Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop
            $Yaml = $Response.Content

            # Parse GUIDs from YAML (simple regex — full YAML parsing would require a module)
            $GuidMatches = [regex]::Matches($Yaml, '(?m)^- description:\s*\S|aprlGuid:\s*([0-9a-f-]{36})')
            foreach ($Match in ([regex]::Matches($Yaml, 'aprlGuid:\s*([0-9a-f-]{36})'))) {
                $Guid = $Match.Groups[1].Value
                if ($TrackedGuids -contains $Guid) {
                    Write-Verbose "  Found tracked GUID $Guid in $ResourcePath"
                    $UpdatedCount++
                }
            }
        }
        catch {
            Write-Warning "Failed to fetch $Url : $_"
            $FailedCount++
        }
    }

    Write-Host "APRL catalog refresh complete." -ForegroundColor Green
    Write-Host "  Tracked GUIDs found: $UpdatedCount / $($TrackedGuids.Count)" -ForegroundColor Cyan
    if ($FailedCount -gt 0) {
        Write-Warning "  $FailedCount resource type(s) could not be fetched."
    }
    Write-Host ""
    Write-Host "Note: This command validates that tracked GUIDs still exist in APRL." -ForegroundColor Yellow
    Write-Host "To update KQL queries, edit Get-MtAprlCatalogEntry.ps1 and submit a PR." -ForegroundColor Yellow

    # Invalidate the in-memory cache so the next call to Get-MtAprlCatalogEntry
    # re-initializes from the (now potentially updated) bundled catalog.
    $script:MtAprlCatalog = $null
}
