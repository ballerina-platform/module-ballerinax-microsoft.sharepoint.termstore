# Taxonomy Migration Setup

This example demonstrates how to automate enterprise content taxonomy migration in a SharePoint Term Store using the Microsoft SharePoint Term Store connector. The script retrieves the existing Term Store configuration, creates a new term group called "Product Catalog", and provisions a multilingual term set called "Product Categories" within that group.

## Prerequisites

1. **Microsoft SharePoint Term Store Setup**
   > Refer to the [Microsoft SharePoint Term Store connector setup guide](https://central.ballerina.io/ballerinax/microsoft.sharepoint.termstore/latest) to register an Azure AD application and obtain the required credentials.

2. For this example, create a `Config.toml` file in the project root with your credentials:

```toml
clientId = "<Your Client ID>"
clientSecret = "<Your Client Secret>"
tenantId = "<Your Tenant ID>"
siteId = "<Your SharePoint Site ID>"
```

## Run the Example

Execute the following command to run the example. The script will print its progress and a migration summary to the console.

```shell
bal run
```
