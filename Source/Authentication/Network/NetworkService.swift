//
//  NetworkService.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 10/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit

/// Unknown or generic errors raised on the network layer
enum NetworkErrors: Error {
	case unknown
}

/// Types conforming to this protocol can be used to perform network calls
protocol NetworkService {

	static func POST<RequestData: Encodable, ResultData: Decodable>(url: String,
																	requestData: RequestData,
																	headers: [String: String]?) -> Promise<ResultData>
}

extension NetworkService {

	static func POST<RequestData: Encodable, ResultData: Decodable>(url: String,
																	requestData: RequestData,
																	headers: [String: String]? = nil) -> Promise<ResultData> {
		return sendData(url: url, requestData: requestData, resultType: ResultData.self, headers: headers)
	}

	/// Performs a POST network call and returns a promise with a generic decodable data
	///
	/// - Parameters:
	///   - url: The url that will be executed
	///   - requestData: An encoded object that will be serialized into JSON object
	///   - resultType: A decodable type, basically a dynamic type of any object that implements decodable
	/// - Returns: A promise with decodable object
	private static func sendData<RequestData: Encodable, ResultData: Decodable>(url: String,
	                                                                            requestData: RequestData,
																				resultType: ResultData.Type,
																				headers: [String: String]? = nil) -> Promise<ResultData> {
		return Promise { fulfill in

			let startTime = Log.timeString

			do {
				let parameters = try Serializer.shared.toDictionary(requestData)

				Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
					.responseData { response in

						let intervalTime = startTime + " - " + Log.timeString
						Log.print(title: "Remote Call", message: url, time: intervalTime)

						guard let object = handleResponse(response: response,
						                                  type: resultType,
						                                  reject: fulfill.reject) else { return }

						fulfill.fulfill(object)
					}

			} catch let error {
				fulfill.reject(error)
			}
		}
	}

	/// This operation handles network responses
	///
	/// - Parameters:
	///   - response: A network response data
	///   - type: A decodable type, basically a dynamic type of any object that implements decodable
	///   - reject: A promise reject closure in case the operation can not be handled
	/// - Returns: A decodable object or nil in case the operation fails
	private static func handleResponse<ResultData: Decodable>(response: DataResponse<Data>,
	                                                          type: ResultData.Type,
	                                                          reject: @escaping (Error) -> Void) -> ResultData? {

		switch (response.response, response.result.value, response.error) {

			case (_, _, let error?):
				reject(error)
				return nil

			case (_, let resultValue?, nil):

				do {
					let object = try Serializer.shared.toObject(type, fromData: resultValue)
					return object
				} catch let error {

					// At first, try to serialize to a NetworkError. If it fails, return a generic error
					guard let networkError = try? Serializer.shared.toObject(NetworkError.self, fromData: resultValue) else {
						reject(error)
						return nil
					}
					
					reject(networkError)

					return nil
				}

			default:
				Log.print(title: "Remote Call Error", message: NetworkErrors.unknown.localizedDescription)
				reject(NetworkErrors.unknown)
				return nil
		}
	}
}
