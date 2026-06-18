WAF policies for Application Gateway and Front Door should be set to Prevention mode so that malicious requests are actively blocked rather than merely logged, providing real protection for web applications.

### Remediation action:

1. In the [Azure portal](https://portal.azure.com), navigate to the WAF policy (search for **Web Application Firewall policies**).
2. Select **Policy settings** in the left menu.
3. Under **Mode**, change the setting from **Detection** to **Prevention**.
4. Click **Save**.
5. Monitor WAF logs after switching to Prevention mode to identify any false positives and tune exclusion rules before they affect legitimate traffic.

Using Azure CLI (Application Gateway WAF):
`az network application-gateway waf-policy policy-setting update --policy-name <policy> --resource-group <rg> --mode Prevention`

#### Related links

- [Azure Web Application Firewall policy overview](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/policy-overview)

<!--- Results --->

%TestResult%
