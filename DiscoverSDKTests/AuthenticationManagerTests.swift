//
//  AuthenticationManagerTests.swift
//  DiscoverSDKTests
//
//  Created by Eduardo Dias on 6/12/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import OHHTTPStubs
import XCTest

class AuthenticationManagerTests: XCTestCase {

	override func setUp() {
		super.setUp()
		CredentialsManager.invalidateToken()
	}
    
    private let token = "token"
    private let publisherId = "mockId"
    private let identityId = "mockPoolId"
    private let headers = ["Content-Type": "application/json"]
    private let username = ""
    private let password = ""
    /*
	func testTokenHasBeenSetAfterAuthentication() {

		let expectation = self.expectation(description: "Access token has not been set after authentication")

		stub(condition: isMethodPOST()) { _ -> OHHTTPStubsResponse in
			return OHHTTPStubsResponse(jsonObject: ["success": true,
			                                        "data": ["identity_pool_id": self.identityId, "publisher_id": self.publisherId,
															 "token": self.token]],
			                           statusCode: 200,
			                           headers: self.headers)
		}

		_ = AuthenticationManager.login(username: "test", password: "test").done {
			XCTAssert(CredentialsManager.token == self.token)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 13.0)
	}

	func testAccessTokenCouldNotBeFoundIssueIsRaised() {

		let expectation = self.expectation(description: "Issue AccessTokenCouldNotBeFound was not raised")

		_ = AuthenticationManager.accessToken().catch { error in
			XCTAssert(error.localizedDescription == AuthenticationManagerError.accessTokenCouldNotBeFound.localizedDescription)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 3.0)
	}
    
    func testLoginWithCognito() {
        
        let expectation = self.expectation(description: "Access token has not been set after authentication")
        
        stub(condition: isMethodPOST()) { _ -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(jsonObject: ["success": true,
                                                    "data": ["identity_pool_id": self.identityId, "publisher_id": self.publisherId,
                                                             "token": self.token]],
                                       statusCode: 200,
                                       headers: self.headers)
        }
        
        _ = AuthenticationManager.login(username: self.username, password: self.password).done {
            XCTAssert(CredentialsManager.token == self.token)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 130.0)
    }*/
}
