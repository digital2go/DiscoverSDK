//
//  DataQualityAnalyser.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 22/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import CoreLocation
import UserNotifications

public let dataQualityChangedNotification = Notification.Name("DataQualityChanged")

class DataQualityAnalyser {

	private var lastLocation: CLLocation?

	private var lastDataQuality: Double = 0.0 {
		didSet {
			guard oldValue != lastDataQuality else { return }
			sendDataQualityNotification(dataQuality: lastDataQuality)
		}
	}

	func dataQuality(location: CLLocation) -> Double {

		let locationChange = lastLocation?.distance(from: location) ?? 1

		lastLocation = location

		guard locationChange >= 1.0 else {
			lastDataQuality = 0.0
			return lastDataQuality
		}

		switch location.horizontalAccuracy {
		case 0..<100:
			let scoreForAccuracy = 0.5 - (location.horizontalAccuracy / 100 * 0.5)
			lastDataQuality = 0.5 + scoreForAccuracy
			return lastDataQuality
		default:
			lastDataQuality = 0.5
			return lastDataQuality
		}
	}

	private func sendDataQualityNotification(dataQuality: Double) {
		NotificationCenter.default.post(name: dataQualityChangedNotification, object: nil, userInfo: ["dataQuality": dataQuality])
	}
}
