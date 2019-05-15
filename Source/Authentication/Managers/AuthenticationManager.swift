//
//  AuthenticationManager.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 14/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import AWSKinesis
import Foundation
import PromiseKit

enum AuthenticationManagerError: Error {
	case accessTokenCouldNotBeFound
}

/// The entity responsible to manage user authentication on the platform
class AuthenticationManager {

	private init() {}

	static var isTokenValid: Bool {
		return !CredentialsManager.isTokenInvalid
	}

	/// Authenticate an user on the platform
	///
	/// - Parameters:
	///   - username: A string that represents the username
	///   - password: A string that represents the password
	/// - Returns: A boolean Promise
	static func login(username: String, password: String) -> Promise<Void> {

		guard CredentialsManager.isTokenInvalid else {
			return Promise<Void>.init()
		}
        
        return Promise { seal in
			_ = AuthenticationServices.login(username: username, password: password).done { response in
				CredentialsManager.accessCredentials = (response.data.token, response.data.identityPoolId, response.data.publisherId)
                AWSConnector.shared.identityPoolId = response.data.identityPoolId
                seal.fulfill(())
			}.catch { error in
				seal.reject(error)
			}
		}
	}

	/// Try to retrieve and return a valid access token
	///
	/// - Returns: A promise containing an access token or an error otherwise
	static func accessToken() -> Promise<String> {

		return Promise { seal in

			guard let token = CredentialsManager.token else {
				seal.reject(AuthenticationManagerError.accessTokenCouldNotBeFound)
				return
			}

			guard CredentialsManager.isTokenInvalid else {
				seal.fulfill(token)
				return
			}
		}
	}
}
