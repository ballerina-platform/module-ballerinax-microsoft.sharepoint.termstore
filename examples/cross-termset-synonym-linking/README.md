# Cross Termset Pin/Reuse Term Linking

This example demonstrates how to link terms across different term sets in a Microsoft SharePoint term store by creating a `pin` relation between an "Invoice" term in a Finance term set and a "Bill" term in a Procurement term set. Per Graph v1.0, termStore relations are `pin` or `reuse` only — true synonyms are modeled as additional non-default labels on a term.

## Prerequisites

1. **Microsoft SharePoint Term Store Setup**
   > Refer to the [Microsoft SharePoint Term Store connector setup guide](https://central.ballerina.io/ballerinax/microsoft.sharepoint.termstore/latest) to obtain credentials and configure your Azure AD application with the required permissions.

2. **Term Store Data Requirements**
   - A SharePoint site with an existing term store
   - A **Finance** term set containing an **Invoice** term
   - A **Procurement** term set containing a **Bill** term
   - The IDs for the site, both term sets, and both terms

3. Create a `Config.toml` file in the example's root directory with your credentials:

```toml
tenantId = "<Your Tenant ID>"
clientId = "<Your Client ID>"
clientSecret = "<Your Client Secret>"
siteId = "<Your Site ID>"
financeSetId = "<Your Finance Term Set ID>"
invoiceTermId = "<Your Invoice Term ID>"
procurementSetId = "<Your Procurement Term Set ID>"
billTermId = "<Your Bill Term ID>"
```

## Run the Example

Execute the following command to run the example. The script will print its progress to the console as it retrieves term sets, fetches individual terms, and creates the synonym relation.

```shell
bal run
```
