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

configurable string tenantId = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string siteId = ?;
configurable string financeSetId = ?;
configurable string invoiceTermId = ?;
configurable string procurementSetId = ?;
configurable string billTermId = ?;

public function main() returns error? {
    termstore:ConnectionConfig config = {
        auth: {
            tokenUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`,
            clientId: clientId,
            clientSecret: clientSecret,
            scopes: ["https://graph.microsoft.com/.default"]
        }
    };

    termstore:Client termstoreClient = check new (config);

    io:println("=== Step 1: Retrieving all term sets in the site termStore ===");
    termstore:MicrosoftGraphTermStoreSetCollectionResponse termSetsResponse =
        check termstoreClient->listSets(siteId);

    termstore:MicrosoftGraphTermStoreSet[]? termSets = termSetsResponse?.value;
    if termSets is termstore:MicrosoftGraphTermStoreSet[] {
        io:println("Found ", termSets.length(), " term set(s) in the termStore:");
        foreach termstore:MicrosoftGraphTermStoreSet termSet in termSets {
            string setId = termSet?.id ?: "unknown";
            io:println("  - Term Set ID: ", setId);
        }
    } else {
        io:println("No term sets found or value is null.");
    }

    io:println("\n=== Step 2: Fetching 'Invoice' term from the Finance term set ===");
    termstore:MicrosoftGraphTermStoreTerm invoiceTerm =
        check termstoreClient->getSetTerm(siteId, financeSetId, invoiceTermId,
            expand = ["relations", "set"],
            selectParam = ["id", "labels", "descriptions", "relations", "set"]
        );

    string invoiceTermIdFetched = invoiceTerm?.id ?: "unknown";
    io:println("Retrieved term ID: ", invoiceTermIdFetched);

    termstore:MicrosoftGraphTermStoreLocalizedLabel[]? invoiceLabels = invoiceTerm?.labels;
    if invoiceLabels is termstore:MicrosoftGraphTermStoreLocalizedLabel[] {
        io:println("Labels for the 'Invoice' term:");
        foreach termstore:MicrosoftGraphTermStoreLocalizedLabel label in invoiceLabels {
            string labelName = label?.name ?: "unnamed";
            string langTag = label?.languageTag ?: "unknown";
            boolean isDefault = label?.isDefault ?: false;
            io:println("  - Label: '", labelName, "' (Language: ", langTag, ", Default: ", isDefault, ")");
        }
    }

    io:println("\n=== Step 3: Fetching 'Bill' term from the Procurement term set ===");
    termstore:MicrosoftGraphTermStoreTerm billTerm =
        check termstoreClient->getSetTerm(siteId, procurementSetId, billTermId,
            expand = ["relations", "set"],
            selectParam = ["id", "labels", "descriptions", "relations", "set"]
        );

    string billTermIdFetched = billTerm?.id ?: "unknown";
    io:println("Retrieved term ID: ", billTermIdFetched);

    termstore:MicrosoftGraphTermStoreLocalizedLabel[]? billLabels = billTerm?.labels;
    if billLabels is termstore:MicrosoftGraphTermStoreLocalizedLabel[] {
        io:println("Labels for the 'Bill' term:");
        foreach termstore:MicrosoftGraphTermStoreLocalizedLabel label in billLabels {
            string labelName = label?.name ?: "unnamed";
            string langTag = label?.languageTag ?: "unknown";
            boolean isDefault = label?.isDefault ?: false;
            io:println("  - Label: '", labelName, "' (Language: ", langTag, ", Default: ", isDefault, ")");
        }
    }

    io:println("\n=== Step 4: Creating a 'pin' relation between 'Invoice' and 'Bill' ===");

    termstore:MicrosoftGraphTermStoreRelation relationPayload = {
        relationship: "pin",
        set: {
            id: procurementSetId
        },
        fromTerm: {
            id: billTermId
        }
    };

    termstore:MicrosoftGraphTermStoreRelation createdRelation =
        check termstoreClient->createSetTermRelation(siteId, financeSetId, invoiceTermId, relationPayload);

    io:println("Successfully created pin relation!");
    string relationId = createdRelation?.id ?: "unknown";
    io:println("  Relation ID: ", relationId);

    termstore:MicrosoftGraphTermStoreRelationType|anydata|() rawRelationship = createdRelation?.relationship;
    if rawRelationship is termstore:MicrosoftGraphTermStoreRelationType {
        io:println("  Relationship type: ", rawRelationship);
    }

    io:println("\n=== Cross-Termset Pin/Reuse Relationship Builder Complete ===");
    io:println("The 'Invoice' term in the Finance term set is now pinned to the");
    io:println("'Bill' term in the Procurement term set via a Graph v1.0 'pin' relation.");
    io:println("Note: Graph v1.0 termStore relations are 'pin' or 'reuse' only.");
    io:println("True synonyms are modeled as additional non-default labels on a term.");
}
