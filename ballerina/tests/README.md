# Running Tests

## Prerequisites

Before running the tests, ensure you have configured the necessary credentials and dependencies for the `microsoft.sharepoint.termstore` connector. Refer to the setup guide in the [connector README](https://github.com/ballerina-platform/module-ballerinax-microsoft.sharepoint.termstore/blob/main/ballerina/README.md) for detailed instructions on obtaining the required credentials.

## Test Structure

The test suite contains two types of tests controlled by the `IS_LIVE_SERVER` flag:

| Group | Description |
|---|---|
| `mock_test` | Runs against an in-process mock HTTP service (no credentials required) |
| `live_test` | Runs against the real Microsoft Graph API (requires valid credentials) |

Both groups cover CRUD operations for the term store hierarchy: **store → groups → sets → terms (children)**. The `mock_test` group additionally includes negative-case tests (404 not found, 400 bad request).

## Running Tests

### Mock Tests (default)

No credentials are required. Run directly from the `ballerina/` directory:

```bash
bal test
```

This starts the mock HTTP service on port 9090 and runs all tests. Since `IS_LIVE_SERVER` defaults to `false`, the client connects to the mock service; tests tagged with `live_test` will run against it as well but no real credentials or network access are needed.

### Live Tests

Live tests interact directly with the Microsoft SharePoint Term Store API. Valid credentials must be provided.

#### Using Environment Variables

```bash
export IS_LIVE_SERVER=true
export SERVICE_URL=https://graph.microsoft.com/v1.0
export CLIENT_ID=<your-client-id>
export CLIENT_SECRET=<your-client-secret>
export TOKEN_URL=https://login.microsoftonline.com/<your-tenant-id>/oauth2/v2.0/token
export SITE_ID=<your-site-id>

bal test --groups live_test
```

#### Using `Config.toml`

Create a `Config.toml` file in the `ballerina/` directory:

```toml
isLiveServer = true
serviceUrl = "https://graph.microsoft.com/v1.0"
clientId = "<your-client-id>"
clientSecret = "<your-client-secret>"
tokenUrl = "https://login.microsoftonline.com/<your-tenant-id>/oauth2/v2.0/token"
siteId = "<your-site-id>"
```

Then run:

```bash
bal test --groups live_test
```

> **Warning:** Live tests create and delete real resources (groups, sets, and terms) in your SharePoint Term Store. Use a non-production site for testing.

### Skipping Live Tests in CI

Set `IS_LIVE_SERVER` to anything other than `"true"` (or leave it unset) to run only mock tests:

```bash
bal test
```
