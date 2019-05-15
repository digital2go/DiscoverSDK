//
//  TokenManagerTests.swift
//  DiscoverSDKTests
//
//  Created by Eduardo Dias on 29/11/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import XCTest

class CredentialsManagerTests: XCTestCase {

	override func setUp() {
		super.setUp()
		CredentialsManager.accessCredentials = ("test_token", "test_identityId", "test_publisherId")
	}

    func testTokenIsSetSucessfully() {
		XCTAssert(CredentialsManager.token == "test_token")
    }

	func testIdentityIdIsSetSucessfully() {
		XCTAssert(CredentialsManager.identityId == "test_identityId")
	}
	
	func testRefreshTokenIsSetSucessfully() {
		XCTAssert(CredentialsManager.publisherId == "test_publisherId")
	}
}
