//
//  AuthenticationServices.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 10/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import Foundation
import PromiseKit

class AuthenticationServices: NetworkService {

	/// Executes a network call and authenticate an user to the platform if passed credentials match
	///
	/// - Parameters:
	///   - username: A string representing the username
	///   - password: A string representing the user password
	/// - Returns: A LoginResponse data containing an access token that will be used to authorize consecutive network calls
	static func login(username: String, password: String) -> Promise<LoginResponse> {
		let loginRequest = LoginRequest(username: username, password: password)
		let jsonHeader = ["Content-Type": "application/json"]
		return POST(url: "\(URLS.base)/apps/cognitologin.json", requestData: loginRequest, headers: jsonHeader)
	}
}
