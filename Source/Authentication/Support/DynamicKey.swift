//
//  DynamicKeys.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 11/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import Foundation

struct DynamicKey: CodingKey {

	var stringValue: String

	init?(stringValue: String) {
		self.stringValue = stringValue
	}

	var intValue: Int? {
		return nil
	}

	init?(intValue: Int) {
		return nil
	}
}

extension KeyedDecodingContainer where Key == DynamicKey {

	func decodeDynamicKeyValues() -> [String: Any] {

		var dict = [String: Any]()

		for key in allKeys {

			if let value = try? decode(String.self, forKey: key) {
				dict[key.stringValue] = value
			} else if let value = try? decode(Bool.self, forKey: key) {
				dict[key.stringValue] = value
			} else if let value = try? decode(Int.self, forKey: key) {
				dict[key.stringValue] = value
			} else if let value = try? decode(Double.self, forKey: key) {
				dict[key.stringValue] = value
			} else if let value = try? decode(Float.self, forKey: key) {
				dict[key.stringValue] = value
			} else if let value = try? nestedContainer(keyedBy: DynamicKey.self, forKey: key) {
				dict[key.stringValue] = value
			}
		}
		return dict
	}
}
