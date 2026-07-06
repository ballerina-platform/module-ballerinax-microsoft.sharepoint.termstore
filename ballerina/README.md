## Overview

[Microsoft SharePoint](https://www.microsoft.com/en-us/microsoft-365/sharepoint/collaboration) is a collaborative platform that enables organizations to manage content, knowledge, and applications to empower teamwork, quickly find information, and seamlessly collaborate across the enterprise.

The `ballerinax/microsoft.sharepoint.termstore` package offers APIs to connect and interact with the [Microsoft SharePoint Term Store API](https://learn.microsoft.com/en-us/graph/api/resources/termstore-store?view=graph-rest-1.0) endpoints, specifically based on [Microsoft Graph REST API v1.0](https://learn.microsoft.com/en-us/graph/api/overview?view=graph-rest-1.0).

> **Note:** This connector manages the taxonomy (groups, term sets, terms) only. Every operation requires a `siteId`, which you can retrieve using the sibling [`ballerinax/microsoft.sharepoint.sites`](https://central.ballerina.io/ballerinax/microsoft.sharepoint.sites) connector (`getSite`/`listSite`). To apply managed-metadata terms to list items (e.g., set a managed-metadata column value), use the [`ballerinax/microsoft.sharepoint.lists`](https://central.ballerina.io/ballerinax/microsoft.sharepoint.lists) connector (`updateItemFields`).

## Setup guide

To use the Microsoft SharePoint Term Store connector, you must have access to the Microsoft SharePoint API through a [Microsoft Azure developer account](https://portal.azure.com/) and obtain client credentials by registering an application in Microsoft Entra. If you do not have a Microsoft account, you can [sign up for a Microsoft account](https://account.microsoft.com/account).

### Step 1: Create a Microsoft Account and Set Up SharePoint Access

1. Navigate to the [Microsoft 365 website](https://www.microsoft.com/en-us/microsoft-365) and sign up for an account or log in if you already have one.

2. Ensure you have a Microsoft 365 Business Basic, Business Standard, Business Premium, or an Enterprise (E1, E3, or E5) plan, as access to the SharePoint Term Store API requires an active SharePoint Online subscription. The Term Store (Managed Metadata Service) is not available on personal or free-tier Microsoft accounts.

### Step 2: Register an Application and Generate Credentials

1. Log in to the [Microsoft Azure Portal](https://portal.azure.com/) using your Microsoft 365 account credentials.

2. In the left-hand navigation menu, select **Microsoft Entra ID** in the top search bar.

3. In the left panel, navigate to **App registrations** and click **New registration**.

   ![New application registration](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/refs/heads/main/docs/resources/new-application-registration.png)

4. Enter a name for your application, select the appropriate **Supported account types** (e.g., "Single tenant only"), and click **Register**.

   ![Application registration details](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/refs/heads/main/docs/resources/application-registration-details.png)

5. Once the application is registered, note down the **Application (client) ID** and **Directory (tenant) ID** from the Overview page.

   ![Client ID and Tenant ID](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/refs/heads/main/docs/resources/client-id-and-tenant-id.png)

6. Navigate to **Certificates & secrets** in the left panel, click **New client secret**, provide a description and expiry period, then click **Add**. Copy the generated **client secret value** immediately.

   ![Create client secret](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/refs/heads/main/docs/resources/create-client-secret.png)

7. Navigate to **API permissions** in the left panel and click **Add a permission**.

   ![Add API permission](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/refs/heads/main/docs/resources/add-api-permission.png)

8. Select **Microsoft Graph** from the available API options.

   ![Microsoft Graph API permission](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/refs/heads/main/docs/resources/microsoft-graph-api-permission.png)

9. Select **Application permissions**, then search for and add the following permissions depending on your use case, then click **Add permissions**.

   | Permission | Operations covered |
   | --- | --- |
   | `TermStore.Read.All` | Read term store data including groups, term sets, and terms |
   | `TermStore.ReadWrite.All` | Read and write term store data including creating, updating, and deleting groups, term sets, and terms |

   > **Tip:** Grant only the permissions your application actually requires. For read-only use cases, `TermStore.Read.All` is sufficient.

   ![API term store permissions](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/refs/heads/main/docs/resources/api-site-permissions.png)

10. Click **Grant admin consent** to approve the permissions for your organization.

    ![Grant admin consent](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/refs/heads/main/docs/resources/grant-admin-consent.png)

11. Construct the `tokenUrl` using the **Directory (tenant) ID** obtained in step 5:

    ```text
    https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/token
    ```

    This is the OAuth 2.0 token endpoint the connector uses to exchange your `clientId` and `clientSecret` for an access token with the `https://graph.microsoft.com/.default` scope.

> **Tip:** You must copy and store the client secret value somewhere safe. It won't be visible again in the Azure Portal after you navigate away from the page, for security reasons.

## Quickstart

To use the `microsoft.sharepoint.termstore` connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

```ballerina
import ballerinax/microsoft.sharepoint.termstore;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the obtained credentials:

    ```toml
    clientId = "<Your_Client_Id>"
    clientSecret = "<Your_Client_Secret>"
    tenantId = "<Your_Tenant_Id>"
    ```

2. Create a `termstore:ConnectionConfig` and initialize the client:

    ```ballerina
    configurable string clientId = ?;
    configurable string clientSecret = ?;
    configurable string tenantId = ?;

    final termstore:Client termstoreClient = check new ({
        auth: <termstore:OAuth2ClientCredentialsGrantConfig>{
            clientId,
            clientSecret,
            tokenUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`,
            scopes: ["https://graph.microsoft.com/.default"]
        }
    });
    ```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### Create a term store group

```ballerina
public function main() returns error? {
    termstore:MicrosoftGraphTermStoreGroup newGroup = {
        displayName: "Product Taxonomy Group",
        description: "Group for managing product-related terms"
    };

    termstore:MicrosoftGraphTermStoreGroup response = check termstoreClient->createGroup("contoso.sharepoint.com,abc123,def456", newGroup);
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `microsoft.sharepoint.termstore` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/tree/main/examples), covering the following use cases:

1. [Product taxonomy hierarchy builder](https://github.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/tree/main/examples/product-taxonomy-hierarchy-builder) - Demonstrates how to build a structured product taxonomy hierarchy using the Ballerina connector for Microsoft SharePoint Term Store.
2. [Taxonomy migration setup](https://github.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/tree/main/examples/taxonomy-migration-setup) - Illustrates how to configure and migrate existing taxonomy data into a SharePoint Term Store.
3. [Cross termset synonym linking](https://github.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/tree/main/examples/cross-termset-synonym-linking) - Demonstrates how to establish synonym relationships between terms across multiple term sets.
4. [Retire obsolete term sets](https://github.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/tree/main/examples/retire-obsolete-term-sets) - Illustrates how to identify and retire outdated term sets from the SharePoint Term Store.
