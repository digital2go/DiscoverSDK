//
//  DiscoverSDKUtils.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 22/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import AdSupport
import CoreBluetooth
import CoreFoundation
import CoreTelephony
import SystemConfiguration.CaptiveNetwork
import WebKit

import Reachability

class DiscoverSDKUtils: NSObject {

	static let shared = DiscoverSDKUtils()

	private var centralManager: CBCentralManager?
	private let reachability = Reachability(hostname: "www.google.com")
	private var peripherals = [CBPeripheral]()
	private let bluetoothState = CBCentralManager()

	private lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
		return formatter
	}()

	private override init() {
		super.init()
		centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
	}

	var wiFiMACAddress: String? {

		var macAddress: String?

		if let interfaces = CNCopySupportedInterfaces() as NSArray? {

			for interface in interfaces {

				if let cfString: CFString = interface as? NSString,
					let interfaceInfo = CNCopyCurrentNetworkInfo(cfString) as NSDictionary? {
					macAddress = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String
					break
				}
			}
		}
		return macAddress ?? "none"
	}

	var wifiSSID: String {

		var ssid = "none"

		if let interfaces = CNCopySupportedInterfaces() as NSArray? {

			for interface in interfaces {

				if let cfString: CFString = interface as? NSString,
					let interfaceInfo = CNCopyCurrentNetworkInfo(cfString) as NSDictionary?,
					let ssidString = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String {
					ssid = ssidString
					break
				}
			}
		}
		return ssid
	}

	var deviceNet: String {
		return reachability?.currentReachabilityString() ?? "none"
	}

	var appName: String {
		guard let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String else {
			return "App Name cannot retrived bundle"
		}
		return appName
	}

	var advertisingIdentifier: String {
		return ASIdentifierManager.shared().advertisingIdentifier.uuidString
	}

	var countryCode: String {
		return Locale.current.regionCode ?? ""
	}

	var userAgent: String {
		return WKWebView().customUserAgent ?? ""
	}

	var isAdvertisingTrackingEnabled: Bool {
		return ASIdentifierManager.shared().isAdvertisingTrackingEnabled
	}

	var deviceModel: String {
		return UIDevice.current.model
	}

	var deviceCarrier: String {
		let phoneInfo = CTTelephonyNetworkInfo()
		return phoneInfo.subscriberCellularProvider?.carrierName ?? ""
	}

	var systemVersion: String {
		return UIDevice.current.systemVersion
	}

	var deviceBatteryLevel: Float {
		return UIDevice.current.batteryLevel * 100.0
	}

	var appState: String {
		let appState: UIApplicationState = UIApplication.shared.applicationState
		return appState == .active ? "foreground" : "background"
	}

	var timeStamp: String {
		return timeStamp(withDate: Date())
	}

	var UTCTimestamp: String {
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		return dateFormatter.string(from: Date())
	}

	func timeStamp(withDate: Date) -> String {
		return dateFormatter.string(from: withDate)
	}

	var bluetoothConnectedDevices: String {
		let peripheralNames = peripherals.compactMap { $0.name }
		return "\(peripheralNames)"
	}

	var bluetoothStatus: String {
		switch bluetoothState.state {
		case .poweredOn:
			return "on"
		case .poweredOff:
			return "off"
		case .resetting:
			return "resetting"
		case .unauthorized:
			return "unauthorized"
		case .unsupported:
			return "unsupported"
		case .unknown:
			return "unknown"
		}
	}

	/***
	 **WIFI Info
	 */

	var wiFiAddress: String {
		var address: String?

		// Get list of all interfaces on the local machine:
		var ifaddr: UnsafeMutablePointer<ifaddrs>?
		guard getifaddrs(&ifaddr) == 0 else { return "" }
		guard let firstAddr = ifaddr else { return "" }

		// For each interface ...
		for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
			let interface = ifptr.pointee

			// Check for IPv4 or IPv6 interface:
			let addrFamily = interface.ifa_addr.pointee.sa_family
			if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

				// Check interface name:
				let name = String(cString: interface.ifa_name)
				if name == "en0" {

					// Convert interface address to a human readable string:
					var addr = interface.ifa_addr.pointee
					var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
					getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
					            &hostname, socklen_t(hostname.count),
					            nil, socklen_t(0), NI_NUMERICHOST)
					address = String(cString: hostname)
				}
			}
		}
		freeifaddrs(ifaddr)

		return address ?? ""
	}

	// Return IP address of WiFi interface (en0) as a String, or `nil`
	var IPAddress6: String {
		var address: String = ""

		// Get list of all interfaces on the local machine:
		var ifaddr: UnsafeMutablePointer<ifaddrs>?
		guard getifaddrs(&ifaddr) == 0 else { return "" }
		guard let firstAddr = ifaddr else { return "" }

		// For each interface ...
		for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
			let interface = ifptr.pointee

			// IPv6 interface:
			let addrFamily = interface.ifa_addr.pointee.sa_family
			if addrFamily == UInt8(AF_INET6) {

				// Check interface name:
				let name = String(cString: interface.ifa_name)
				if name == "en0" {

					// Convert interface address to a human readable string:
					var addr = interface.ifa_addr.pointee
					var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
					getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
					            &hostname, socklen_t(hostname.count),
					            nil, socklen_t(0), NI_NUMERICHOST)
					address = String(cString: hostname)
				}
			}
		}
		freeifaddrs(ifaddr)
		return address
	}

	var appVersion: String {
		let version = Bundle(identifier: "org.cocoapods.DiscoverSDK")?.infoDictionary?["CFBundleShortVersionString"] as? String
		return version ?? ""
	}
}

extension DiscoverSDKUtils: CBCentralManagerDelegate {

	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		guard central.state == .poweredOn else { return }
		centralManager?.scanForPeripherals(withServices: nil, options: nil)
	}

	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		peripherals.append(peripheral)
	}
}
