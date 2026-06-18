Orphaned resources — unattached managed disks, unassociated Standard public IP addresses, empty App Service Plans, and disk snapshots without a source disk — generate ongoing charges without contributing to any workload and should be removed.

### Remediation action:

1. In the [Azure portal](https://portal.azure.com), navigate to **Disks** and filter by **Disk state = Unattached**. Delete disks that are confirmed to be unused (take a snapshot first if needed).
2. Navigate to **Public IP addresses** and filter by **Association = Not associated**. Delete any Standard SKU IPs that are no longer needed.
3. Navigate to **App Service plans** and identify plans with zero apps. Delete empty plans to stop incurring compute charges.
4. Navigate to **Snapshots** and remove any snapshots whose source disk no longer exists and that are not needed for recovery.
5. Use Azure Advisor recommendations under **Cost** to get a consolidated list of orphaned resources across subscriptions.

#### Related links

- [Manage and reduce costs for Azure reservations](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/manage-reserved-capacity)

<!--- Results --->

%TestResult%
