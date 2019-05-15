//
//  LoginResponse.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 10/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import Foundation

struct LoginResponse: Decodable {

	struct Data: Decodable {
		let token: String
		let publisherId: String
        let identityPoolId: String
	}

	let data: Data
}
