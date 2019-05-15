//
//  LoginRequest.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 10/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import Foundation

struct LoginRequest: Encodable {
	let username: String
	let password: String
}
