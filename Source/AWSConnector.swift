//
//  AWSConnector.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 22/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import AWSCore
import Foundation

class DeveloperAuthenticatedIdentityProvider: AWSCognitoCredentialsProviderHelper {
	override func token() -> AWSTask<NSString> {
		
		self.identityId = CredentialsManager.identityId

		return AWSTask(result: CredentialsManager.token as NSString?)
	}
}

class AWSConnector {

	static let shared = AWSConnector()

	public private(set) var connected = false

	private init() {}

	var identityPoolId: String! {
		didSet {
			guard identityPoolId != nil else { return }
			initialize()
		}
	}

	private lazy var configuration: AWSServiceConfiguration = {
		
		let identityPoolId = CredentialsManager.identityId ?? ""
	
		let developerAuthenticatedIdentity =  DeveloperAuthenticatedIdentityProvider(regionType: .USWest2, 
												   identityPoolId: identityPoolId, 
												   useEnhancedFlow: true, 
												   identityProviderManager: nil)
		let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityProvider: developerAuthenticatedIdentity)
		return AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider)
	}()

	private func initialize() {
		AWSServiceManager.default().defaultServiceConfiguration = configuration
		connected = true
	}
}
