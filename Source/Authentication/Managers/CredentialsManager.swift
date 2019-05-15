//
//  TokenManager.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 14/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import Foundation

/// Store and manage the access token
enum CredentialsManager {

	private static let sevenDays = TimeInterval(604800)

	private enum Keys: String {
		case token, refreshToken, refreshTokenDate, identityId, publisherId
	}

	static var accessCredentials: (String, String, String)? {
		didSet {
			guard let (token, identityId, publisherId) = accessCredentials else { return }
			self.token = token
			self.identityId = identityId
			self.publisherId = publisherId
		}
	}

	static var isTokenInvalid: Bool {
		guard let refreshTokenDate = refreshTokenDate else { return true }
		return Date().timeIntervalSince(refreshTokenDate) > sevenDays
	}

	static func invalidateToken() {
		token = nil
		refreshToken = nil
		refreshTokenDate = nil
	}

	private(set) static var token: String? {
		get {
			return UserDefaults.standard.string(forKey: Keys.token.rawValue)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: Keys.token.rawValue)
		}
	}
	
	private(set) static var identityId: String? {
		get {
			return UserDefaults.standard.string(forKey: Keys.identityId.rawValue)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: Keys.identityId.rawValue)
		}
	}
	
	private(set) static var publisherId: String? {
		get {
			return UserDefaults.standard.string(forKey: Keys.publisherId.rawValue)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: Keys.publisherId.rawValue)
		}
	}

	private(set) static var refreshToken: String? {
		get {
			return UserDefaults.standard.string(forKey: Keys.refreshToken.rawValue)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: Keys.refreshToken.rawValue)
		}
	}

	private static var refreshTokenDate: Date? {
		get {
			return UserDefaults.standard.object(forKey: Keys.refreshTokenDate.rawValue) as? Date
		}
		set {
			UserDefaults.standard.set(newValue, forKey: Keys.refreshTokenDate.rawValue)
		}
	}
}
