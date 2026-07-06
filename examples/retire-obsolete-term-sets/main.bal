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
configurable string groupId = ?;
configurable string setId = ?;

public function main() returns error? {
    termstore:ConnectionConfig config = {
        auth: {
            clientId: clientId,
            clientSecret: clientSecret,
            tokenUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`,
            scopes: ["https://graph.microsoft.com/.default"]
        }
    };

    termstore:Client termstoreClient = check new (config);

    io:println("=== Step 1: Auditing Terms in Term Set ===");
    termstore:MicrosoftGraphTermStoreTermCollectionResponse termsResponse =
        check termstoreClient->listGroupSetTerms(siteId, groupId, setId, top = 50);

    termstore:MicrosoftGraphTermStoreTerm[]? terms = termsResponse.value;
    if terms is termstore:MicrosoftGraphTermStoreTerm[] {
        io:println("Total terms found in term set: ", terms.length());
        foreach termstore:MicrosoftGraphTermStoreTerm term in terms {
            io:println("  Term ID: ", term.id ?: "N/A");
        }
    } else {
        io:println("No terms found in the term set.");
    }

    io:println("");
    io:println("=== Step 2: Marking Term Set as Deprecated and Closed ===");

    termstore:MicrosoftGraphTermStoreSet deprecationPayload = {
        description: "[DEPRECATED] This term set has been retired as part of taxonomy restructuring. It is closed for new tagging. Please refer to the updated taxonomy for current term sets.",
        "isAvailableForTagging": false
    };

    error? patchResult = termstoreClient->updateGroupSet(siteId, groupId, setId, deprecationPayload);

    if patchResult is error {
        io:println("Error updating term set: ", patchResult.message());
        return patchResult;
    } else {
        io:println("Term set successfully marked as deprecated and closed for tagging.");
        io:println("  - Description updated to reflect deprecation status.");
        io:println("  - isAvailableForTagging set to false.");
    }

    io:println("");
    io:println("=== Step 3: Retrieving Parent Group for Governance Audit ===");

    termstore:MicrosoftGraphTermStoreGroup parentGroup =
        check termstoreClient->getGroupSetParentGroup(siteId, groupId, setId,
            selectParam = ["id", "displayName", "description", "scope", "createdDateTime", "parentSiteId"]
        );

    io:println("Parent Group Details:");
    string? groupIdVal = parentGroup?.id;
    io:println("  Group ID       : ", groupIdVal ?: "N/A");
    string? displayName = parentGroup?.displayName;
    io:println("  Display Name   : ", displayName ?: "N/A");
    string? descriptionVal = parentGroup?.description;
    io:println("  Description    : ", descriptionVal ?: "N/A");
    string? createdDateTime = parentGroup?.createdDateTime;
    io:println("  Created On     : ", createdDateTime ?: "N/A");
    string? parentSiteId = parentGroup?.parentSiteId;
    io:println("  Parent Site ID : ", parentSiteId ?: "N/A");

    termstore:MicrosoftGraphTermStoreTermGroupScope|record {}|() scopeVal = parentGroup?.scope;
    if scopeVal is termstore:MicrosoftGraphTermStoreTermGroupScope {
        io:println("  Scope          : ", scopeVal);
    } else {
        io:println("  Scope          : N/A");
    }

    io:println("");
    io:println("=== Taxonomy Lifecycle Management Summary ===");
    io:println("Audit and retirement workflow completed successfully.");
    io:println("  - Term inventory captured for set ID: ", setId);
    io:println("  - Term set marked as deprecated and closed for new tagging.");
    io:println("  - Parent group '", displayName ?: "N/A", "' confirmed as governance owner.");
    io:println("Compliance record: Term set retired under group ID: ", groupId, " on site: ", siteId);
}
