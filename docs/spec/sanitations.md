_Author_: Nuvindu \
_Created_: 2026-06-23 \
_Updated_: 2026-06-23 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Microsoft SharePoint Termstore. 
The OpenAPI specification is obtained from [Microsoft Graph REST API v1.0 OpenAPI description](https://github.com/microsoftgraph/msgraph-metadata/tree/master/openapi/v1.0).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. **Updated operation IDs with suitable names**: The operation IDs in the original specification were auto-generated and not descriptive. They have been replaced with meaningful, readable names that accurately reflect the operation's purpose.

2. **Dropped recurring `sites` prefix in remote functions**: The original remote function names included a redundant `sites` prefix that was repetitive given the context of the connector. This prefix has been removed to improve readability and conciseness.

3. **Removed numeric suffixes from method names**: Numeric suffixes such as `3155` that appeared in some method names were artifacts of the OpenAPI generation process. These have been removed to produce cleaner and more intuitive method names.

4. **Shortened lengthy method names**: Several method names were excessively long. These have been shortened while preserving their descriptive intent to improve usability.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/openapi.json --mode client --client-methods remote --license docs/license.txt -o ballerina
```

Note: The license year is hardcoded to 2026, change if necessary.
