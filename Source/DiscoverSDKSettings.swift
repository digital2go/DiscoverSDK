//
//  DiscoverSDKSettings.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 22/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import Foundation

public struct Settings {

	// Location Core Identity Pool
	static let defaultIdentityPoolId = "us-west-2:99013dfc-ccf8-4616-9c06-fff31ad70a09"

	private static let defaultStream = "DiscoverSDKStream"

	private static let defaultThreshold = 20
	private static let defaultInterval = 5.0

	private(set) var autoStartMonitoring = true

	private(set) var useDefaultDataStream = true

	private(set) var stream = defaultStream
	private(set) var identityPoolId = defaultIdentityPoolId
	private(set) var timeInterval = defaultInterval
	private(set) var threshold = defaultThreshold

	/// The settings that will be used on DiscoverSDK
	///
	/// - Parameters:
	///   - stream: A AWS Kinesis data stream
	///   - identityPoolId: A AWS Cognito identityPoolId
	///   - timeInterval: The interval in seconds the records will be saved (default is 5 second)
	///   - threshold: The amount of time records will be saved until the threshold is reached (default is 20)
	///   - autoStartMonitoring: A bool that indicates if the monitoring should start immediately after instantiation (default is true)
	public init(stream: String, identityPoolId: String, timeInterval: Double, threshold: Int, autoStartMonitoring: Bool) {
		self.stream = stream
		self.identityPoolId = identityPoolId
		self.timeInterval = timeInterval
		self.threshold = threshold
		self.autoStartMonitoring = autoStartMonitoring
	}

	public init(stream: String) {
		self.stream = stream
	}

	public init(identityPoolId: String) {
		self.identityPoolId = identityPoolId
	}

	public init(stream: String, identityPoolId: String) {
		self.stream = stream
		self.identityPoolId = identityPoolId
	}

	public init(timeInterval: Double, threshold: Int, useDefaultDataStream: Bool = true) {
		self.timeInterval = timeInterval
		self.threshold = threshold
		self.useDefaultDataStream = useDefaultDataStream
	}

	public init(autoStartMonitoring: Bool) {
		self.autoStartMonitoring = autoStartMonitoring
	}

	public init() {}
}
