Every enabled Azure subscription should have at least one Cost Management budget with alert notifications to ensure no subscription can accumulate unexpected spend without triggering an alert.

### Remediation action:

1. In the [Azure portal](https://portal.azure.com), navigate to **Cost Management + Billing** > **Cost Management** > **Budgets** and switch to each subscription that lacks a budget.
2. Click **+ Add** to create a budget scoped to that subscription.
3. Set a monthly amount, reset period, and at least one alert threshold (for example, 80% of budget).
4. Add notification email addresses and confirm the alert is enabled.
5. Click **Create**. Repeat for every subscription identified as missing coverage.

Using Azure CLI:
`az consumption budget create --budget-name <name> --amount <amount> --time-grain Monthly --start-date <YYYY-MM-DD> --end-date <YYYY-MM-DD> --scope /subscriptions/<subscriptionId>`

#### Related links

- [Tutorial: Create and manage Azure budgets](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-acm-create-budgets)

<!--- Results --->

%TestResult%
