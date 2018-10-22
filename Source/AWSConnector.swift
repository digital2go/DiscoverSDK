//
//  AWSConnector.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 22/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import AWSCore
import Foundation

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
		let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: identityPoolId)
		return AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider)
	}()

	private func initialize() {
		AWSServiceManager.default().defaultServiceConfiguration = configuration
		connected = true
	}
}
