# Examples

The `microsoft.sharepoint.termstore` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/tree/main/examples), covering use cases like building product taxonomy hierarchies, migrating taxonomy setups, and managing term set lifecycles.

1. [Product taxonomy hierarchy builder](https://github.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/tree/main/examples/product-taxonomy-hierarchy-builder) - Build and organize a structured product taxonomy hierarchy within the SharePoint term store.

2. [Taxonomy migration setup](https://github.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/tree/main/examples/taxonomy-migration-setup) - Set up and configure taxonomy structures in SharePoint term store as part of a migration process.

3. [Cross termset synonym linking](https://github.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/tree/main/examples/cross-termset-synonym-linking) - Link synonyms across multiple term sets to ensure consistent terminology throughout the SharePoint term store.

4. [Retire obsolete term sets](https://github.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/tree/main/examples/retire-obsolete-term-sets) - Identify and retire outdated or unused term sets from the SharePoint term store to maintain a clean taxonomy.

## Prerequisites

1. Generate Microsoft SharePoint Term Store credentials to authenticate the connector as described in the [Setup guide](https://central.ballerina.io/ballerinax/microsoft.sharepoint.termstore/latest#setup-guide).

2. For each example, create a `Config.toml` file with the related configuration. Here's an example of how your `Config.toml` file should look:

    ```toml
    clientId = "<Your_Client_Id>"
    clientSecret = "<Your_Client_Secret>"
    tenantId = "<Your_Tenant_Id>"
    siteId = "<Your_Site_Id>"
    ```

## Running an Example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```
