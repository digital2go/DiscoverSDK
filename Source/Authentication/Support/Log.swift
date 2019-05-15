//
//  Log.swift
//  DiscoverSDK
//
//  Created by Eduardo Dias on 10/10/18.
//  Copyright © 2018 Locally. All rights reserved.
//

import Foundation

private struct LogTimeFormatter {

	private var formatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "ss.SSS"
		return formatter
	}()

	func timeString() -> String {
		return formatter.string(from: Date())
	}
}

struct Log {

	private init() {}

	private static let formatter = LogTimeFormatter()

	static var timeString: String {
		return formatter.timeString()
	}

	public static func print(title: String, message: String, time: String = timeString) {
		#if DEBUG

		let debugString = """
		DiscoverSDK: \(title) (\(time))

		\(message)
		------------------------------------------------------
		"""

		Swift.print(debugString)

		#endif
	}
}
