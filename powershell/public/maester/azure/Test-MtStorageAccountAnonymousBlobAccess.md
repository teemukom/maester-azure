Storage Accounts should have anonymous blob public access disabled so that blobs cannot be read by unauthenticated users, preventing accidental data exposure from misconfigured container permissions.

### Remediation action:

1. In the [Azure portal](https://portal.azure.com), navigate to the Storage Account.
2. Select **Configuration** in the left menu.
3. Under **Blob public access**, select **Disabled**.
4. Click **Save**.
5. If any containers previously relied on anonymous access for legitimate scenarios, replace them with Shared Access Signatures (SAS) or Azure AD-based access.

Using Azure CLI:
`az storage account update --name <account> --resource-group <rg> --allow-blob-public-access false`

#### Related links

- [Configure anonymous read access for containers and blobs](https://learn.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-configure)

<!--- Results --->

%TestResult%
