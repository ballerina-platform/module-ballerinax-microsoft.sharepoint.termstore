# Product Taxonomy Hierarchy Builder

This example demonstrates how to build a two-level product taxonomy hierarchy in SharePoint Managed Metadata Service using the Microsoft SharePoint Term Store API. The script lists existing term sets under a product catalog group, creates a top-level term ("Electronics"), and then creates a nested sub-term ("Smartphones") beneath it.

## Prerequisites

1. **Microsoft SharePoint Term Store Setup**
   > Refer to the [Microsoft SharePoint Term Store connector setup guide](https://central.ballerina.io/ballerinax/microsoft.sharepoint.termstore/latest) to obtain the required credentials and configure your Azure AD application with the appropriate permissions.

2. **Configuration**

   Create a `Config.toml` file in the project root and add your credentials:

   ```toml
   clientId = "<Your Client ID>"
   clientSecret = "<Your Client Secret>"
   tenantId = "<Your Tenant ID>"
   siteId = "<Your SharePoint Site ID>"
   groupId = "<Your Term Store Group ID>"
   productCatalogSetId = "<Your Product Catalog Term Set ID>"
   ```

## Run the Example

Execute the following command to run the example. The script will print its progress to the console, showing each step of the hierarchy creation process.

```shell
bal run
```
