//
//  DiscoverSDK.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 22/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import AWSKinesis
import CoreLocation
import DeviceKit

public protocol DiscoverSDKDelegate: class {

	func didUpdateRecords(records: [String: Any])
	func didReachThreshold()

	// Optional protocols
	func didUpdateDataQuality(quality: Double)
	func dataToIncludeOnRecords() -> [String: Any]
	func didUpdateRecordsWithError(error: Error)
	func didReachThresholdWithError(error: Error)

	var shouldSendRecords: Bool { get }
}

public extension DiscoverSDKDelegate {
	func didUpdateDataQuality(quality: Double) {}
	func dataToIncludeOnRecords() -> [String: Any] { return [:] }
	func didUpdateRecordsWithError(error: Error) {}
	func didReachThresholdWithError(error: Error) {}

	var shouldSendRecords: Bool { return true }
}

public protocol DiscoverSDKLocationDelegate: class {
	func didAuthorizedLocationMonitoring()
	func didNotAuthorizedLocationMonitoring()
}

public class DiscoverSDK: NSObject {

	weak var delegate: DiscoverSDKDelegate?

	private weak var locationDelegate: DiscoverSDKLocationDelegate?

	let dataQualityAnalyser = DataQualityAnalyser()

	public var connected: Bool {
		return AWSConnector.shared.connected
	}

	public func openLocationPermissionSettings() {

		guard let bundleId = Bundle.main.bundleIdentifier,
			let url = URL(string: "\(UIApplicationOpenSettingsURLString)&path=LOCATION/\(bundleId)") else {   
			return
		}
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

	// MARK: - Private properties

	private var settings: Settings!

	private var shouldStartMonitoringAfterPermission = true

	public var isMonitoringAuthorized: Bool {
		let authorizationStatus = CLLocationManager.authorizationStatus()
		return authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
	}

	// MARK: - Private Properties

	private lazy var locationManager: CLLocationManager = {
		let locationManager = CLLocationManager()
		locationManager.distanceFilter = kCLLocationAccuracyBest
		locationManager.allowsBackgroundLocationUpdates = true
		locationManager.pausesLocationUpdatesAutomatically = false
		locationManager.delegate = self
		return locationManager
	}()

	private var timer: Timer!

	private var timeCounting = 0 {
		didSet {
			if timeCounting > settings.threshold {
				timeCounting = 0
				submitAllRecords()
			}
		}
	}

	private lazy var fireHoseRecorder = {
		AWSFirehoseRecorder.default()
	}()

	// MARK: - Initialization

	public static var shared = DiscoverSDK()

	/// Creates an unique DiscoverSDK connection
	///
	/// - Parameters:
	///   - delegate: An entity that implements DiscoverSDKDelegate protocol
	///   - settings: The settings that will be used to configure DiscoverSDK
	/// - Returns: Returns a DiscoverSDK instance
	public func connect(delegate: DiscoverSDKDelegate? = nil, settings: Settings = Settings()) {

		self.delegate = delegate

		self.settings = settings

		AWSConnector.shared.identityPoolId = settings.useDefaultDataStream ? settings.identityPoolId : nil

		autoMonitorIfReady(autoMonitoring: settings.autoStartMonitoring, monitoringAuthorized: isMonitoringAuthorized)
	}

	public func connect(delegate: DiscoverSDKDelegate?) {
		self.delegate = delegate
	}

	private func autoMonitorIfReady(autoMonitoring: Bool, monitoringAuthorized: Bool) {

		switch (autoMonitoring, monitoringAuthorized) {
		case (true, true):
			startMonitoringLocation()
		case (true, false):
			requestLocationPermission()
		default:
			requestLocationPermission(startMonitoringAfterPermission: false)
		}
	}

	private override init() {
		super.init()
		UIDevice.current.isBatteryMonitoringEnabled = true
	}

	// MARK: - Public API

	public func startMonitoringLocation() {

		guard isMonitoringAuthorized else {
			requestLocationPermission()
			return
		}
		startUpdatingLocationAndHeading()
	}

	public func stopMonitoringLocation() {
		locationManager.stopUpdatingLocation()
		stopTimer()
	}

	private func stopTimer() {
		if timer.isValid {
			timer.invalidate()
		}
		timer = nil
	}

	// MARK: - Private API

	public func requestLocationPermission(delegate: DiscoverSDKLocationDelegate? = nil, startMonitoringAfterPermission: Bool = true) {

		guard !isMonitoringAuthorized else {
			delegate?.didAuthorizedLocationMonitoring()
			return
		}

		locationDelegate = delegate

		shouldStartMonitoringAfterPermission = startMonitoringAfterPermission
		locationManager.requestAlwaysAuthorization()
	}

	private func scheduleTimer() {
		timer = Timer.scheduledTimer(timeInterval: settings.timeInterval,
		                             target: self,
		                             selector: #selector(DiscoverSDK.startUpdatingLocationAndHeading),
		                             userInfo: nil,
		                             repeats: true)
	}

	@objc
	func startUpdatingLocationAndHeading() {
		locationManager.startUpdatingLocation()
		locationManager.startUpdatingHeading()
	}

	private var headingData: [String: Any] {

		var headingDict: [String: Any] = [:]

		guard let headingData = locationManager.heading else { return headingDict }

		headingDict["magnetic_heading"] = headingData.magneticHeading as NSObject
		headingDict["true_heading"] = headingData.trueHeading as NSObject
		headingDict["heading_accuracy"] = headingData.headingAccuracy as NSObject
		headingDict["x"] = headingData.x as NSObject
		headingDict["y"] = headingData.y as NSObject
		headingDict["z"] = headingData.z as NSObject

		return headingDict
	}

	private func saveRecord(withLocation location: CLLocation) {

		let dataQualityIndex = dataQualityAnalyser.dataQuality(location: location)
		let device = Device()

		var record: [String: Any] = [:]
		record["publisher_id"] = "" // TODO: Move publisher_id key as mandatory to the Settings
		record["app"] = DiscoverSDKUtils.shared.appName as NSObject
		record["idfa"] = DiscoverSDKUtils.shared.advertisingIdentifier as NSObject
		record["cntry"] = DiscoverSDKUtils.shared.countryCode as NSObject
		record["agent"] = DiscoverSDKUtils.shared.userAgent as NSObject
		record["opt_out"] = DiscoverSDKUtils.shared.isAdvertisingTrackingEnabled as NSObject
		record["device_model"] = DiscoverSDKUtils.shared.deviceModel as NSObject
		record["manufacturer"] = "Apple" as NSObject
		record["carrier"] = DiscoverSDKUtils.shared.deviceCarrier as NSObject
		record["alt"] = location.altitude as NSObject
		record["bat"] = DiscoverSDKUtils.shared.deviceBatteryLevel as NSObject
		record["bgrnd"] = DiscoverSDKUtils.shared.appState as NSObject
		record["hdng_avilable"] = CLLocationManager.headingAvailable().description as NSObject
		record["horz_acc"] = location.horizontalAccuracy as NSObject
		record["ipv4"] = DiscoverSDKUtils.shared.wiFiAddress as NSObject
		record["ipv6"] = DiscoverSDKUtils.shared.IPAddress6 as NSObject
		record["lat"] = location.coordinate.latitude as NSObject
		record["lng"] = location.coordinate.longitude as NSObject
		record["capt_at"] = DiscoverSDKUtils.shared.timeStamp as NSObject
		record["loc_at"] = DiscoverSDKUtils.shared.timeStamp(withDate: location.timestamp) as NSObject
		record["net"] = DiscoverSDKUtils.shared.deviceNet as NSObject
		record["speed"] = location.speed as NSObject
		record["vert_acc"] = location.verticalAccuracy as NSObject
		record["wifi_bssid"] = DiscoverSDKUtils.shared.wiFiAddress as NSObject
		record["wifi_ssid"] = DiscoverSDKUtils.shared.wifiSSID as NSObject
		record["bluetooth_devices"] = DiscoverSDKUtils.shared.bluetoothConnectedDevices as NSObject
		record["utc_timestamp"] = DiscoverSDKUtils.shared.UTCTimestamp as NSObject
		record["event_type"] = "GPS" as NSObject
		record["device_os"] = UIDevice.current.systemVersion as NSObject
		record["device_version"] = device.description as NSObject
		record["mock"] = device.isSimulator.description as NSObject
		record["sdk_version"] = DiscoverSDKUtils.shared.appVersion as NSObject
		record["bluetooth_status"] = DiscoverSDKUtils.shared.bluetoothStatus as NSObject
		record["data_quality"] = dataQualityIndex as NSObject
		record["hdng"] = headingData

		delegate?.didUpdateDataQuality(quality: dataQualityIndex)

		if let delegateData = delegate?.dataToIncludeOnRecords() {
			record = record.merging(delegateData) { first, _ in first }
		}

		saveRecord(record: record)
	}

	private func saveRecord(record: [String: Any]) {

		guard settings.useDefaultDataStream else {
			delegate?.didUpdateRecords(records: record)
			return
		}

		let jsonData = try? JSONSerialization.data(withJSONObject: record, options: [])

		fireHoseRecorder.saveRecord(jsonData, streamName: settings.stream).continueWith { (task) -> Void in

			switch task.error {
			case let error?:
				self.delegate?.didUpdateRecordsWithError(error: error)
			default:
				self.delegate?.didUpdateRecords(records: record)
			}
		}
	}

	private func submitAllRecords() {

		guard settings.useDefaultDataStream else {
			delegate?.didReachThreshold()
			return
		}

		fireHoseRecorder.submitAllRecords().continueWith { (task) -> Void in

			switch task.error {
			case let error?:
				self.delegate?.didReachThresholdWithError(error: error)
			default:
				self.delegate?.didReachThreshold()
			}
		}
	}
}

// MARK: - CLLocationManagerDelegate

extension DiscoverSDK: CLLocationManagerDelegate {

	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

		if delegate?.shouldSendRecords ?? true {
			saveRecord(withLocation: locations[0] as CLLocation)
			timeCounting += 1
		}

		locationManager.stopUpdatingLocation()

		guard timer == nil else { return }
		scheduleTimer()
	}

	public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}

	public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

		switch status {
		case .authorizedAlways, .authorizedWhenInUse:
			locationDelegate?.didAuthorizedLocationMonitoring()
		case .denied:
			locationDelegate?.didNotAuthorizedLocationMonitoring()
		default: break
		}

		guard shouldStartMonitoringAfterPermission else { return }
		startMonitoringLocation()
	}
}