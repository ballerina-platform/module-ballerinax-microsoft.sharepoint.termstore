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

import ballerina/os;
import ballerina/test;

configurable boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
configurable string serviceUrl = os:getEnv("SERVICE_URL");
configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string tokenUrl = os:getEnv("TOKEN_URL");
configurable string siteId = os:getEnv("SITE_ID") == "" ? "mock-site-id" : os:getEnv("SITE_ID");

isolated string createdGroupId = "";
isolated string createdSetId = "";
isolated string createdTermId = "";

final Client termstoreClient = check initClient();

isolated function initClient() returns Client|error {
    if isLiveServer {
        return check new Client(
            {
                auth: <OAuth2ClientCredentialsGrantConfig>{
                    clientId,
                    clientSecret,
                    tokenUrl,
                    scopes: ["https://graph.microsoft.com/.default"]
                }
            },
            serviceUrl
        );
    }
    return check new Client({auth: {token: "mock-token"}}, "http://localhost:9090");
}

@test:Config {groups: ["live_test", "mock_test"]}
isolated function testGetTermStore() returns error? {
    MicrosoftGraphTermStoreStore response = check termstoreClient->getTermStore(siteId);
    test:assertTrue(response.id !is (), msg = "Term store should have an ID");
}

@test:Config {groups: ["live_test", "mock_test"]}
isolated function testCreateGroup() returns error? {
    MicrosoftGraphTermStoreGroup payload = {
        displayName: "Test Taxonomy Group",
        description: "A test taxonomy group for unit testing",
        scope: "global"
    };
    MicrosoftGraphTermStoreGroup response = check termstoreClient->createGroup(siteId, payload);
    test:assertTrue(response.id !is (), msg = "Created group should have an ID");
    test:assertEquals(response?.displayName, "Test Taxonomy Group",
            msg = "Created group display name should match the request payload");
    lock {
        createdGroupId = response.id ?: "";
    }
}

@test:Config {dependsOn: [testCreateGroup], groups: ["live_test", "mock_test"]}
isolated function testListGroups() returns error? {
    MicrosoftGraphTermStoreGroupCollectionResponse response =
            check termstoreClient->listGroups(siteId);
    MicrosoftGraphTermStoreGroup[] groups = response.value ?: [];
    test:assertTrue(groups.length() > 0, msg = "Group list should contain at least one group");
}

@test:Config {dependsOn: [testCreateGroup], groups: ["live_test", "mock_test"]}
isolated function testGetGroup() returns error? {
    string groupId;
    lock {
        groupId = createdGroupId;
    }
    MicrosoftGraphTermStoreGroup response = check termstoreClient->getGroup(siteId, groupId);
    test:assertEquals(response.id, groupId, msg = "Retrieved group ID should match the created group");
    test:assertEquals(response?.displayName, "Test Taxonomy Group",
            msg = "Retrieved group display name should match");
}

@test:Config {dependsOn: [testGetGroup], groups: ["live_test", "mock_test"]}
isolated function testUpdateGroup() returns error? {
    string groupId;
    lock {
        groupId = createdGroupId;
    }
    MicrosoftGraphTermStoreGroup payload = {
        description: "Updated description for the test taxonomy group"
    };
    MicrosoftGraphTermStoreGroup|error response = termstoreClient->updateGroup(siteId, groupId, payload);
    test:assertFalse(response is error, msg = "Group update should not return an error");
}

@test:Config {dependsOn: [testUpdateGroup, testDeleteGroupSet], groups: ["live_test", "mock_test"]}
isolated function testDeleteGroup() returns error? {
    string groupId;
    lock {
        groupId = createdGroupId;
    }
    error? response = termstoreClient->deleteGroup(siteId, groupId);
    test:assertEquals(response, (), msg = "Group deletion should return no error (204 No Content)");
}

@test:Config {dependsOn: [testCreateGroup], groups: ["live_test", "mock_test"]}
isolated function testCreateGroupSet() returns error? {
    string groupId;
    lock {
        groupId = createdGroupId;
    }
    MicrosoftGraphTermStoreSet payload = {
        localizedNames: [
            {name: "Test Term Set", languageTag: "en-US"}
        ],
        description: "A test term set for unit testing"
    };
    MicrosoftGraphTermStoreSet response = check termstoreClient->createGroupSet(siteId, groupId, payload);
    test:assertTrue(response.id !is (), msg = "Created term set should have an ID");
    lock {
        createdSetId = response.id ?: "";
    }
}

@test:Config {dependsOn: [testCreateGroupSet], groups: ["live_test", "mock_test"]}
isolated function testListGroupSets() returns error? {
    string groupId;
    lock {
        groupId = createdGroupId;
    }
    MicrosoftGraphTermStoreSetCollectionResponse response =
            check termstoreClient->listGroupSets(siteId, groupId);
    MicrosoftGraphTermStoreSet[] sets = response.value ?: [];
    test:assertTrue(sets.length() > 0, msg = "Term set list should contain at least one set");
}

@test:Config {dependsOn: [testCreateGroupSet], groups: ["live_test", "mock_test"]}
isolated function testGetGroupSet() returns error? {
    string groupId;
    string setId;
    lock { groupId = createdGroupId; }
    lock { setId = createdSetId; }
    MicrosoftGraphTermStoreSet response = check termstoreClient->getGroupSet(siteId, groupId, setId);
    test:assertEquals(response.id, setId, msg = "Retrieved term set ID should match the created set");
}

@test:Config {dependsOn: [testGetGroupSet], groups: ["live_test", "mock_test"]}
isolated function testUpdateGroupSet() returns error? {
    string groupId;
    string setId;
    lock { groupId = createdGroupId; }
    lock { setId = createdSetId; }
    MicrosoftGraphTermStoreSet payload = {
        description: "[UPDATED] Updated description for the test term set"
    };
    error? response = termstoreClient->updateGroupSet(siteId, groupId, setId, payload);
    test:assertEquals(response, (), msg = "Term set update should return no error (204 No Content)");
}

@test:Config {dependsOn: [testUpdateGroupSet, testDeleteGroupSetChild], groups: ["live_test", "mock_test"]}
isolated function testDeleteGroupSet() returns error? {
    string groupId;
    string setId;
    lock { groupId = createdGroupId; }
    lock { setId = createdSetId; }
    error? response = termstoreClient->deleteGroupSet(siteId, groupId, setId);
    test:assertEquals(response, (), msg = "Term set deletion should return no error (204 No Content)");
}

@test:Config {dependsOn: [testCreateGroupSet], groups: ["live_test", "mock_test"]}
isolated function testCreateGroupSetChild() returns error? {
    string groupId;
    string setId;
    lock { groupId = createdGroupId; }
    lock { setId = createdSetId; }
    MicrosoftGraphTermStoreTerm payload = {
        labels: [
            {name: "Test Term", languageTag: "en-US", isDefault: true}
        ],
        descriptions: [
            {description: "A test term for unit testing", languageTag: "en-US"}
        ]
    };
    MicrosoftGraphTermStoreTerm response =
            check termstoreClient->createGroupSetChild(siteId, groupId, setId, payload);
    test:assertTrue(response.id !is (), msg = "Created term should have an ID");
    test:assertEquals(response?.labels, payload?.labels,
            msg = "Created term labels should match the request payload");
    lock {
        createdTermId = response.id ?: "";
    }
}

@test:Config {dependsOn: [testCreateGroupSetChild], groups: ["live_test", "mock_test"]}
isolated function testListGroupSetChildren() returns error? {
    string groupId;
    string setId;
    lock { groupId = createdGroupId; }
    lock { setId = createdSetId; }
    MicrosoftGraphTermStoreTermCollectionResponse response =
            check termstoreClient->listGroupSetChildren(siteId, groupId, setId);
    MicrosoftGraphTermStoreTerm[] terms = response.value ?: [];
    test:assertTrue(terms.length() > 0, msg = "Term list should contain at least one term");
}

@test:Config {dependsOn: [testCreateGroupSetChild], groups: ["live_test", "mock_test"]}
isolated function testGetGroupSetChild() returns error? {
    string groupId;
    string setId;
    string termId;
    lock { groupId = createdGroupId; }
    lock { setId = createdSetId; }
    lock { termId = createdTermId; }
    MicrosoftGraphTermStoreTerm response =
            check termstoreClient->getGroupSetChild(siteId, groupId, setId, termId);
    test:assertEquals(response.id, termId, msg = "Retrieved term ID should match the created term");
}

@test:Config {dependsOn: [testGetGroupSetChild], groups: ["live_test", "mock_test"]}
isolated function testUpdateGroupSetChild() returns error? {
    string groupId;
    string setId;
    string termId;
    lock { groupId = createdGroupId; }
    lock { setId = createdSetId; }
    lock { termId = createdTermId; }
    MicrosoftGraphTermStoreTerm payload = {
        descriptions: [
            {description: "Updated description for the test term", languageTag: "en-US"}
        ]
    };
    error? response = termstoreClient->updateGroupSetChild(siteId, groupId, setId, termId, payload);
    test:assertEquals(response, (), msg = "Term update should return no error (204 No Content)");
}

@test:Config {dependsOn: [testUpdateGroupSetChild], groups: ["live_test", "mock_test"]}
isolated function testDeleteGroupSetChild() returns error? {
    string groupId;
    string setId;
    string termId;
    lock { groupId = createdGroupId; }
    lock { setId = createdSetId; }
    lock { termId = createdTermId; }
    error? response = termstoreClient->deleteGroupSetChild(siteId, groupId, setId, termId);
    test:assertEquals(response, (), msg = "Term deletion should return no error (204 No Content)");
}

@test:Config {groups: ["mock_test"]}
isolated function testGetNonExistentGroup() {
    if isLiveServer {
        return;
    }
    MicrosoftGraphTermStoreGroup|error response =
            termstoreClient->getGroup(siteId, "00000000-0000-0000-0000-000000000000");
    test:assertTrue(response is error,
            msg = "Getting a non-existent group should return an error (404)");
}

@test:Config {groups: ["mock_test"]}
isolated function testDeleteNonExistentGroup() {
    if isLiveServer {
        return;
    }
    error? response =
            termstoreClient->deleteGroup(siteId, "00000000-0000-0000-0000-000000000000");
    test:assertTrue(response is error,
            msg = "Deleting a non-existent group should return an error (404)");
}

@test:Config {groups: ["mock_test"]}
isolated function testGetNonExistentSet() {
    if isLiveServer {
        return;
    }
    MicrosoftGraphTermStoreSet|error response =
            termstoreClient->getGroupSet(siteId, mockGroupId, "00000000-0000-0000-0000-000000000000");
    test:assertTrue(response is error,
            msg = "Getting a non-existent term set should return an error (404)");
}

@test:Config {groups: ["mock_test"]}
isolated function testGetNonExistentTerm() {
    if isLiveServer {
        return;
    }
    MicrosoftGraphTermStoreTerm|error response =
            termstoreClient->getGroupSetChild(siteId, mockGroupId, mockSetId,
                "00000000-0000-0000-0000-000000000000");
    test:assertTrue(response is error,
            msg = "Getting a non-existent term should return an error (404)");
}

@test:Config {groups: ["mock_test"]}
isolated function testCreateGroupWithoutDisplayName() {
    if isLiveServer {
        return;
    }
    MicrosoftGraphTermStoreGroup payload = {
        description: "Group with no display name"
    };
    MicrosoftGraphTermStoreGroup|error response = termstoreClient->createGroup(siteId, payload);
    test:assertTrue(response is error,
            msg = "Creating a group without a displayName should return an error (400)");
}

@test:Config {groups: ["mock_test"]}
isolated function testCreateSetWithoutLocalizedNames() {
    if isLiveServer {
        return;
    }
    MicrosoftGraphTermStoreSet payload = {
        description: "Set with no localized names"
    };
    MicrosoftGraphTermStoreSet|error response =
            termstoreClient->createGroupSet(siteId, mockGroupId, payload);
    test:assertTrue(response is error,
            msg = "Creating a term set without localizedNames should return an error (400)");
}

@test:Config {groups: ["mock_test"]}
isolated function testCreateTermWithoutLabels() {
    if isLiveServer {
        return;
    }
    MicrosoftGraphTermStoreTerm payload = {
        descriptions: [
            {description: "Term with no labels", languageTag: "en-US"}
        ]
    };
    MicrosoftGraphTermStoreTerm|error response =
            termstoreClient->createGroupSetChild(siteId, mockGroupId, mockSetId, payload);
    test:assertTrue(response is error,
            msg = "Creating a term without labels should return an error (400)");
}
