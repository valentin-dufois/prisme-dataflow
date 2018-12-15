//
//  Data.swift
//  dataflow
//
//  Created by Valentin Dufois on 05/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

// MARK: - Extension to proving a convenient init from an inputStream
extension Data {
	/// Init a Data objet with the content of the given InputStream
	///
	/// - Parameter input: An InputStream to get data from
	init(reading input: InputStream) {
		self.init()

		let bufferSize = 512
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

		while input.hasBytesAvailable {
			let read = input.read(buffer, maxLength: bufferSize)
			self.append(buffer, count: read)
		}

		buffer.deallocate()
	}
}
