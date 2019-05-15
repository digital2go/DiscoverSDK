//
//  NetworkError.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 11/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import Foundation

struct NetworkError: Error {

	let code: Int
	let message: String
	let reasons: [String: Any]
	let exception: String

	enum CodingKeys: String, CodingKey {
		case data
	}

	enum DataKeys: String, CodingKey {
		case code, message, errors, exception
	}

	enum ExceptionKeys: String, CodingKey {
		case className = "class"
	}
}

extension NetworkError: Decodable {

	init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)
		let dataKeysContainer = try container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)

		code = try dataKeysContainer.decode(Int.self, forKey: .code)
		message = try dataKeysContainer.decode(String.self, forKey: .message)

		let errorsContainer = try dataKeysContainer.nestedContainer(keyedBy: DynamicKey.self, forKey: .errors)
		reasons = errorsContainer.decodeDynamicKeyValues()

		let exceptionContainer = try dataKeysContainer.nestedContainer(keyedBy: ExceptionKeys.self, forKey: .exception)
		exception = try exceptionContainer.decode(String.self, forKey: .className)
	}
}
