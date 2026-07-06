// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerinax/microsoft.sharepoint.termstore;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string tenantId = ?;
configurable string siteId = ?;
configurable string groupId = ?;
configurable string productCatalogSetId = ?;

public function main() returns error? {
    termstore:ConnectionConfig config = {
        auth: {
            clientId: clientId,
            clientSecret: clientSecret,
            tokenUrl: "https://login.microsoftonline.com/" + tenantId + "/oauth2/v2.0/token",
            scopes: ["https://graph.microsoft.com/.default"]
        }
    };

    termstore:Client termstoreClient = check new (config);

    io:println("=== Step 1: Listing existing term sets under the product catalog group ===");

    termstore:MicrosoftGraphTermStoreSetCollectionResponse existingSets = check termstoreClient->listGroupSets(siteId, groupId);

    termstore:MicrosoftGraphTermStoreSet[]? setList = existingSets.value;
    if setList is termstore:MicrosoftGraphTermStoreSet[] {
        io:println("Found " + setList.length().toString() + " term set(s) in the group:");
        foreach termstore:MicrosoftGraphTermStoreSet termSet in setList {
            string setIdValue = termSet?.id ?: "N/A";
            io:println("  - Term Set ID: " + setIdValue);
        }
    } else {
        io:println("No term sets found in the group.");
    }

    io:println("");
    io:println("=== Step 2: Creating top-level term 'Electronics' in the product catalog term set ===");

    termstore:MicrosoftGraphTermStoreTerm electronicsTerm = {
        labels: [
            {
                name: "Electronics",
                languageTag: "en-US",
                isDefault: true
            }
        ],
        descriptions: [
            {
                description: "All electronic products and devices",
                languageTag: "en-US"
            }
        ]
    };

    termstore:MicrosoftGraphTermStoreTerm createdElectronicsTerm = check termstoreClient->createGroupSetChild(siteId, groupId, productCatalogSetId, electronicsTerm);

    string electronicsTermId = createdElectronicsTerm?.id ?: "";
    io:println("Successfully created 'Electronics' term.");
    io:println("  - Term ID: " + electronicsTermId);

    string? electronicsCreatedAt = createdElectronicsTerm?.createdDateTime;
    if electronicsCreatedAt is string {
        io:println("  - Created At: " + electronicsCreatedAt);
    }

    io:println("");
    io:println("=== Step 3: Creating sub-term 'Smartphones' under 'Electronics' ===");

    if electronicsTermId == "" {
        return error("Failed to retrieve the ID of the newly created 'Electronics' term. Cannot create sub-term.");
    }

    termstore:MicrosoftGraphTermStoreTerm smartphonesTerm = {
        labels: [
            {
                name: "Smartphones",
                languageTag: "en-US",
                isDefault: true
            }
        ],
        descriptions: [
            {
                description: "Mobile smartphones and handsets",
                languageTag: "en-US"
            }
        ]
    };

    termstore:MicrosoftGraphTermStoreTerm createdSmartphonesTerm = check termstoreClient->createSetTermChild(siteId, productCatalogSetId, electronicsTermId, smartphonesTerm);

    string smartphonesTermId = createdSmartphonesTerm?.id ?: "";
    io:println("Successfully created 'Smartphones' sub-term under 'Electronics'.");
    io:println("  - Term ID: " + smartphonesTermId);

    string? smartphonesCreatedAt = createdSmartphonesTerm?.createdDateTime;
    if smartphonesCreatedAt is string {
        io:println("  - Created At: " + smartphonesCreatedAt);
    }

    io:println("");
    io:println("=== Product Catalog Term Hierarchy Summary ===");
    io:println("Product Catalog Term Set (ID: " + productCatalogSetId + ")");
    io:println("  └── Electronics (ID: " + electronicsTermId + ")");
    io:println("        └── Smartphones (ID: " + smartphonesTermId + ")");
    io:println("");
    io:println("Product hierarchy successfully built in SharePoint Managed Metadata Service.");
}
