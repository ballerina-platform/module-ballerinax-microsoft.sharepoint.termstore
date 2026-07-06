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
import ballerina/time;
import ballerinax/microsoft.sharepoint.termstore;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string tenantId = ?;
configurable string siteId = ?;

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

    io:println("=== Enterprise Content Taxonomy Migration ===");
    io:println("");

    io:println("Step 1: Retrieving Term Store configuration for site: ", siteId);

    termstore:MicrosoftGraphTermStoreStore termStoreInfo = check termstoreClient->getTermStore(siteId, selectParam = ["id", "defaultLanguageTag", "languageTags", "groups"]);

    string termStoreInfoId = termStoreInfo.id ?: "N/A";
    string termStoreDefaultLang = termStoreInfo.defaultLanguageTag ?: "N/A";
    io:println("Term Store ID: ", termStoreInfoId);
    io:println("Default Language: ", termStoreDefaultLang);

    string[]? languageTags = termStoreInfo.languageTags;
    if languageTags is string[] {
        io:println("Supported Languages: ", languageTags);
    }

    termstore:MicrosoftGraphTermStoreGroup[]? existingGroups = termStoreInfo.groups;
    if existingGroups is termstore:MicrosoftGraphTermStoreGroup[] {
        io:println("Existing Groups Count: ", existingGroups.length());
        foreach termstore:MicrosoftGraphTermStoreGroup grp in existingGroups {
            string grpDisplayName = grp?.displayName ?: "Unnamed";
            string grpId = grp.id ?: "N/A";
            io:println("  - Group: ", grpDisplayName, " (ID: ", grpId, ")");
        }
    }

    io:println("");

    time:Utc currentTime = time:utcNow();
    string groupName = string `Product Catalog ${currentTime[0]}`;

    io:println("Step 2: Creating Term Store Group '", groupName, "'...");

    termstore:MicrosoftGraphTermStoreGroup newGroupPayload = {
        displayName: groupName,
        description: "Taxonomy group for organizing product catalog metadata across the organization",
        scope: "global"
    };

    termstore:MicrosoftGraphTermStoreGroup createdGroup = check termstoreClient->createGroup(siteId, newGroupPayload);

    string groupId = createdGroup.id ?: "";
    string createdGroupDisplayName = createdGroup?.displayName ?: "N/A";
    string createdGroupDescription = createdGroup?.description ?: "N/A";
    anydata createdGroupScopeVal = createdGroup?.scope;
    string createdGroupScope = createdGroupScopeVal is string ? createdGroupScopeVal : "N/A";
    io:println("Successfully created Term Store Group:");
    io:println("  Name: ", createdGroupDisplayName);
    io:println("  ID: ", groupId);
    io:println("  Scope: ", createdGroupScope);
    io:println("  Description: ", createdGroupDescription);

    if groupId == "" {
        return error("Failed to retrieve the ID of the newly created group. Cannot proceed to create term set.");
    }

    io:println("");

    io:println("Step 3: Creating Term Set 'Product Categories' in group: ", groupId);

    termstore:MicrosoftGraphTermStoreSet newTermSetPayload = {
        localizedNames: [
            {
                languageTag: "en-US",
                name: "Product Categories"
            }
        ],
        description: "Hierarchical classification of product categories supporting global content strategy"
    };

    termstore:MicrosoftGraphTermStoreSet createdTermSet = check termstoreClient->createGroupSet(siteId, groupId, newTermSetPayload);

    string createdTermSetId = createdTermSet.id ?: "N/A";
    string createdTermSetDescription = createdTermSet.description ?: "N/A";

    io:println("Successfully created Term Set:");
    io:println("  ID: ", createdTermSetId);
    io:println("  Description: ", createdTermSetDescription);

    termstore:MicrosoftGraphTermStoreLocalizedName[]? localizedNames = createdTermSet.localizedNames;
    if localizedNames is termstore:MicrosoftGraphTermStoreLocalizedName[] {
        io:println("  Multilingual Labels:");
        foreach termstore:MicrosoftGraphTermStoreLocalizedName localizedName in localizedNames {
            string langTag = localizedName?.languageTag ?: "N/A";
            string langName = localizedName?.name ?: "N/A";
            io:println("    [", langTag, "] ", langName);
        }
    }

    io:println("");
    io:println("=== Taxonomy Migration Summary ===");
    io:println("Term Store ID     : ", termStoreInfoId);
    io:println("New Group         : Product Catalog (ID: ", groupId, ")");
    io:println("New Term Set      : Product Categories (ID: ", createdTermSetId, ")");
    io:println("Migration Status  : Completed Successfully");
    io:println("");
    io:println("The 'Product Catalog' group and 'Product Categories' term set have been");
    io:println("successfully provisioned in the SharePoint Term Store. Content editors can");
    io:println("now begin tagging content using the new managed metadata taxonomy.");
}
