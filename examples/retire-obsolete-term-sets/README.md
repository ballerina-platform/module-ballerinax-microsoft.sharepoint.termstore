# Retire Obsolete Term Sets

This example demonstrates how to automate the retirement of obsolete term sets in Microsoft SharePoint's term store. The script audits all terms within a specified term set, marks the term set as deprecated and closed for tagging, and retrieves parent group details for governance audit purposes.

## Prerequisites

1. **Microsoft SharePoint Term Store Setup**
   > Refer to the [Microsoft SharePoint Term Store connector setup guide](https://central.ballerina.io/ballerinax/microsoft.sharepoint.termstore/latest) to register an Azure AD application and obtain the required credentials.

2. For this example, create a `Config.toml` file in the project root with your credentials:

```toml
tenantId = "<Your Tenant ID>"
clientId = "<Your Client ID>"
clientSecret = "<Your Client Secret>"
siteId = "<Your Site ID>"
groupId = "<Your Group ID>"
setId = "<Your Set ID>"
```

## Run the Example

Execute the following command to run the example. The script will print its progress and audit results to the console.

```shell
bal run
```
