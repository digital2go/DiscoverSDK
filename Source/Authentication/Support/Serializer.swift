//
//  Serializer.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 10/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import Foundation

typealias AnyData = [String: Any]

enum SerializationError: Error {
	case noDecodingError
	case dateCouldNotBeDeserialized
	case noEncodingError
}

/// A serializer entity used to encode and decode network objects
class Serializer {

	static let shared = Serializer()

	private init() {}

	private let datesFormatting = ["yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd'T'HH:mm:ss.SSSZ"]

	private let errorTitle = "Serialization Error"

	private let formatter = DateFormatter()

	private lazy var encoder: JSONEncoder = {
		let encoder = JSONEncoder()
		//encoder.dateEncodingStrategy = .custom(customDateFormatter)
		encoder.keyEncodingStrategy = .convertToSnakeCase
		return encoder
	}()

	private lazy var decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .custom(customDateFormatter)
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()

	// MARK: - Public API
	func toObject<Object>(_ type: Object.Type, fromData data: Data) throws -> Object where Object: Decodable {

		do {
			return try decoder.decode(type, from: data)
		} catch let error {

			guard let decodingError = error as? DecodingError else {
				Log.print(title: errorTitle, message: SerializationError.noDecodingError
					.localizedDescription)
				throw error
			}

			switch decodingError {
			case let .keyNotFound (_, context):
				printDecodingError(fromContext: context)
			case let .dataCorrupted(context):
				printDecodingError(fromContext: context)
			case let .typeMismatch(_, context):
				printDecodingError(fromContext: context)
			case let .valueNotFound(_, context):
				printDecodingError(fromContext: context)
			}
			throw error
		}
	}

	func toDictionary<Object>(_ value: Object) throws -> AnyData? where Object: Encodable {

		do {
			let encoded = try encoder.encode(value)
			return try JSONSerialization.jsonObject(with: encoded, options: []) as? AnyData
		} catch let error {

			guard let encodingError = error as? EncodingError else {
				Log.print(title: errorTitle, message: SerializationError.noEncodingError.localizedDescription)
				throw error
			}

			switch encodingError {
			case let .invalidValue (_, context):
				printEncodingError(fromContext: context)
			}
			throw error
		}
	}

	private func customDateFormatter(_ decoder: Decoder) throws -> Date {

		let dateString = try decoder.singleValueContainer().decode(String.self)

		for dateFormatting in datesFormatting {
			formatter.dateFormat = dateFormatting
			if let date = formatter.date(from: dateString) {
				return date
			}
		}
		Log.print(title: errorTitle, message: dateString + " cannot be deserialized")
		throw SerializationError.dateCouldNotBeDeserialized
	}

	// MARK: - Error Logs
	private func printEncodingError(fromContext context: EncodingError.Context) {
		let stringPath = context.codingPath.map {"\($0)"}.joined(separator: " -> ")
		Log.print(title: errorTitle, message: stringPath + context.debugDescription)
	}

	private func printDecodingError(fromContext context: DecodingError.Context) {
		let stringPath = context.codingPath.map {"\($0)"}.joined(separator: " -> ")
		Log.print(title: errorTitle, message: stringPath + context.debugDescription)
	}
}
