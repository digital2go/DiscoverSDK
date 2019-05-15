//
//  NetworkServiceTests.swift
//  DiscoverSDKTests
//
//  Created by Eduardo Dias on 15/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import OHHTTPStubs
import PromiseKit
import XCTest

struct MockRequest: Encodable {}

struct MockResponse: Decodable {
	let name: String
	let address: String
}

class NetworkServiceMock: NetworkService {
	static func post() -> Promise<MockResponse> {
		return POST(url: "http://www.google.com", requestData: MockRequest())
	}
}

class NetworkServiceTests: XCTestCase {
/*
	func testNetworkSucceedWithNetworkError() {

		let expectation = self.expectation(description: "Network fails with NetworkError")

		stub(condition: isMethodPOST()) { _ -> OHHTTPStubsResponse in
			 	   OHHTTPStubsResponse(jsonObject: ["name": "Mike", "address": "123 Pacific Highway - North Sydney"],
			                           statusCode: 401,
			                           headers: ["Content-Type": "application/json"])
		}

		_ = NetworkServiceMock.post().done { _ in
			expectation.fulfill()
		}.catch { error in
			XCTFail(error.localizedDescription)
		}
		waitForExpectations(timeout: 3.0)
	}

	func testNetworkFailsWithEmptyData() {

		let expectation = self.expectation(description: "Network fails with empty data")

		stub(condition: isMethodPOST()) { _ -> OHHTTPStubsResponse in
				   OHHTTPStubsResponse(jsonObject: [:],
			                           statusCode: 200,
			                           headers: ["Content-Type": "application/json"])
		}

		_ = NetworkServiceMock.post().done { _ in

			expectation.fulfill()

		}.catch { error in

			guard error is NetworkError else {
				expectation.fulfill()
				return
			}

			XCTFail(error.localizedDescription)
		}
		waitForExpectations(timeout: 3.0)
	}

	func testNetworkFailsWithNetworkOfflineNetwork() {

		let expectation = self.expectation(description: "Returns an error due offline network connection")

		stub(condition: isMethodPOST()) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue), userInfo: nil)
			return OHHTTPStubsResponse(error: notConnectedError)
		}

		_ = NetworkServiceMock.post().done { _ in

			expectation.fulfill()

		}.catch { error in

			guard error is NetworkError else {
				XCTAssertEqual(-1009, (error as NSError).code)
				expectation.fulfill()
				return
			}

			XCTFail(error.localizedDescription)
		}
		waitForExpectations(timeout: 3.0)
	}

	func testNetworkFailsWithTimeOut() {

		let expectation = self.expectation(description: "Returns an error due network timeout")

		stub(condition: isMethodPOST()) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: Int(CFNetworkErrors.cfurlErrorTimedOut.rawValue), userInfo: nil)
			return OHHTTPStubsResponse(error: notConnectedError)
		}

		_ = AuthenticationServices.login(username: "", password: "").done { _ in

			expectation.fulfill()

		}.catch { error in

			guard error is NetworkError else {
				XCTAssertEqual(-1001, (error as NSError).code)
				expectation.fulfill()
				return
			}

			XCTFail(error.localizedDescription)
		}
		waitForExpectations(timeout: 3.0)
	}*/
}
