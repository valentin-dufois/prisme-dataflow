//
//  Data.swift
//  dataflow
//
//  Created by Valentin Dufois on 05/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

extension Data {
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
