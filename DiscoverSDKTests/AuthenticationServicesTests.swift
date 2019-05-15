//
//  AuthenticationServicesTest.swift
//  DiscoverSDKTests
//
//  Created by Eduardo Dias on 11/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import OHHTTPStubs
import XCTest

class AuthenticationServicesTests: XCTestCase {
    
    private let token = "token"
    private let publisherId = "mockId"
    private let identityPoolId = "mockIdentity"
    private let headers = ["Content-Type": "application/json"]
    private let username = "username"
    private let password = "password"

	func testLoginSucceed() {

		let expectation = self.expectation(description: "Authentication serializes with success")
        
        let data: [AnyHashable: Any] = ["data": ["token": self.token, "publisher_id": self.publisherId, "identity_pool_id": self.identityPoolId]]
        
        stub(condition: isMethodPOST()) { _ -> OHHTTPStubsResponse in
            OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: self.headers)
        }

		_ = AuthenticationServices.login(username: self.username, password: self.password).done { _ in

			expectation.fulfill()

		}.catch { error in

			XCTFail(error.localizedDescription)
		}
		waitForExpectations(timeout: 3.0)
	}

	func testLoginFailsWithNetworkError() {

		let expectation = self.expectation(description: "Authentication fails with NetworkError")

		stub(condition: isMethodPOST()) { _ -> OHHTTPStubsResponse in
			 	OHHTTPStubsResponse(jsonObject: ["data": ["code": 422,
			                                                 "url": "appslogin.json",
			                                                 "message": "2 validation errors occurred",
			                                                 "errorCount": 2,
			                                                 "errors": [
			                                                 	"username": [
			                                                 		"_empty": "This field cannot be left empty"
			                                                 	],
			                                                 	"password": [
			                                                 		"_empty": "This field cannot be left empty"
			                                                 	]
			                                                 ],
			                                                 "exception": [
			                                                 	"class": "App\\Error\\Exception\\ValidationException",
			                                                 	"code": 422,
			                                                 	"message": "2 validation errors occurred"
			]]],
			                           statusCode: 401,
			                           headers: ["Content-Type": "application/json"])
		}

		_ = AuthenticationServices.login(username: "", password: "").done { _ in

			expectation.fulfill()

		}.catch { error in

			guard error is NetworkError else {
				XCTFail(error.localizedDescription)
				return
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: 3.0)
	}
}
