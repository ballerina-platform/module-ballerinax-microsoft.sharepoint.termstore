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

import ballerina/http;

final string mockStoreId = "store-00000000-0000-0000-0000-000000000001";
final string mockGroupId = "group-00000000-0000-0000-0000-000000000001";
final string mockSetId = "set-00000000-0000-0000-0000-000000000001";
final string mockTermId = "term-00000000-0000-0000-0000-000000000001";
final string mockCreatedDateTime = "2026-01-01T00:00:00Z";

service / on new http:Listener(9090) {

    resource function get sites/[string siteId]/termStore()
            returns MicrosoftGraphTermStoreStore {
        return {
            id: mockStoreId,
            defaultLanguageTag: "en-US",
            languageTags: ["en-US", "fr-FR"]
        };
    }

    resource function get sites/[string siteId]/termStore/groups()
            returns MicrosoftGraphTermStoreGroupCollectionResponse {
        return {
            value: [
                {
                    id: mockGroupId,
                    displayName: "Test Taxonomy Group",
                    description: "A test taxonomy group for unit testing",
                    scope: "global",
                    createdDateTime: mockCreatedDateTime
                }
            ]
        };
    }

    resource function post sites/[string siteId]/termStore/groups(
            @http:Payload MicrosoftGraphTermStoreGroup payload)
            returns MicrosoftGraphTermStoreGroup|http:BadRequest {
        if payload?.displayName == () {
            return http:BAD_REQUEST;
        }
        return {
            id: mockGroupId,
            displayName: payload?.displayName,
            description: payload?.description,
            scope: payload?.scope,
            createdDateTime: mockCreatedDateTime
        };
    }

    resource function get sites/[string siteId]/termStore/groups/[string groupId]()
            returns MicrosoftGraphTermStoreGroup|http:NotFound {
        if groupId != mockGroupId {
            return http:NOT_FOUND;
        }
        return {
            id: mockGroupId,
            displayName: "Test Taxonomy Group",
            description: "A test taxonomy group for unit testing",
            scope: "global",
            createdDateTime: mockCreatedDateTime
        };
    }

    resource function patch sites/[string siteId]/termStore/groups/[string groupId](
            @http:Payload MicrosoftGraphTermStoreGroup payload)
            returns MicrosoftGraphTermStoreGroup|http:NotFound {
        if groupId != mockGroupId {
            return http:NOT_FOUND;
        }
        return {
            id: mockGroupId,
            displayName: payload?.displayName ?: "Test Taxonomy Group",
            description: payload?.description,
            scope: payload?.scope,
            createdDateTime: mockCreatedDateTime
        };
    }

    resource function delete sites/[string siteId]/termStore/groups/[string groupId]()
            returns http:NoContent|http:NotFound {
        if groupId != mockGroupId {
            return http:NOT_FOUND;
        }
        return http:NO_CONTENT;
    }

    resource function get sites/[string siteId]/termStore/groups/[string groupId]/sets()
            returns MicrosoftGraphTermStoreSetCollectionResponse|http:NotFound {
        if groupId != mockGroupId {
            return http:NOT_FOUND;
        }
        return {
            value: [
                {
                    id: mockSetId,
                    description: "A test term set for unit testing",
                    createdDateTime: mockCreatedDateTime,
                    localizedNames: [
                        {name: "Test Term Set", languageTag: "en-US"}
                    ]
                }
            ]
        };
    }

    resource function post sites/[string siteId]/termStore/groups/[string groupId]/sets(
            @http:Payload MicrosoftGraphTermStoreSet payload)
            returns MicrosoftGraphTermStoreSet|http:BadRequest|http:NotFound {
        if groupId != mockGroupId {
            return http:NOT_FOUND;
        }
        if payload?.localizedNames == () {
            return http:BAD_REQUEST;
        }
        return {
            id: mockSetId,
            description: payload?.description,
            localizedNames: payload?.localizedNames,
            createdDateTime: mockCreatedDateTime
        };
    }

    resource function get sites/[string siteId]/termStore/groups/[string groupId]/sets/[string setId]()
            returns MicrosoftGraphTermStoreSet|http:NotFound {
        if groupId != mockGroupId || setId != mockSetId {
            return http:NOT_FOUND;
        }
        return {
            id: mockSetId,
            description: "A test term set for unit testing",
            createdDateTime: mockCreatedDateTime,
            localizedNames: [
                {name: "Test Term Set", languageTag: "en-US"}
            ]
        };
    }

    resource function patch sites/[string siteId]/termStore/groups/[string groupId]/sets/[string setId](
            @http:Payload MicrosoftGraphTermStoreSet payload)
            returns http:NoContent|http:NotFound {
        if groupId != mockGroupId || setId != mockSetId {
            return http:NOT_FOUND;
        }
        return http:NO_CONTENT;
    }

    resource function delete sites/[string siteId]/termStore/groups/[string groupId]/sets/[string setId]()
            returns http:NoContent|http:NotFound {
        if groupId != mockGroupId || setId != mockSetId {
            return http:NOT_FOUND;
        }
        return http:NO_CONTENT;
    }

    resource function get sites/[string siteId]/termStore/groups/[string groupId]/sets/[string setId]/children()
            returns MicrosoftGraphTermStoreTermCollectionResponse|http:NotFound {
        if groupId != mockGroupId || setId != mockSetId {
            return http:NOT_FOUND;
        }
        return {
            value: [
                {
                    id: mockTermId,
                    createdDateTime: mockCreatedDateTime,
                    labels: [
                        {name: "Test Term", languageTag: "en-US", isDefault: true}
                    ],
                    descriptions: [
                        {description: "A test term for unit testing", languageTag: "en-US"}
                    ]
                }
            ]
        };
    }

    resource function post sites/[string siteId]/termStore/groups/[string groupId]/sets/[string setId]/children(
            @http:Payload MicrosoftGraphTermStoreTerm payload)
            returns MicrosoftGraphTermStoreTerm|http:BadRequest|http:NotFound {
        if groupId != mockGroupId || setId != mockSetId {
            return http:NOT_FOUND;
        }
        if payload?.labels == () {
            return http:BAD_REQUEST;
        }
        return {
            id: mockTermId,
            labels: payload?.labels,
            descriptions: payload?.descriptions,
            createdDateTime: mockCreatedDateTime
        };
    }

    resource function get sites/[string siteId]/termStore/groups/[string groupId]/sets/[string setId]/children/[string termId]()
            returns MicrosoftGraphTermStoreTerm|http:NotFound {
        if groupId != mockGroupId || setId != mockSetId || termId != mockTermId {
            return http:NOT_FOUND;
        }
        return {
            id: mockTermId,
            createdDateTime: mockCreatedDateTime,
            labels: [
                {name: "Test Term", languageTag: "en-US", isDefault: true}
            ],
            descriptions: [
                {description: "A test term for unit testing", languageTag: "en-US"}
            ]
        };
    }

    resource function patch sites/[string siteId]/termStore/groups/[string groupId]/sets/[string setId]/children/[string termId](
            @http:Payload MicrosoftGraphTermStoreTerm payload)
            returns http:NoContent|http:NotFound {
        if groupId != mockGroupId || setId != mockSetId || termId != mockTermId {
            return http:NOT_FOUND;
        }
        return http:NO_CONTENT;
    }

    resource function delete sites/[string siteId]/termStore/groups/[string groupId]/sets/[string setId]/children/[string termId]()
            returns http:NoContent|http:NotFound {
        if groupId != mockGroupId || setId != mockSetId || termId != mockTermId {
            return http:NOT_FOUND;
        }
        return http:NO_CONTENT;
    }
}
