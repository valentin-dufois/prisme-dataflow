//
//  streamEmitterDelegate.swift
//  dataflow
//
//  Created by Valentin Dufois on 06/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

/// The stream Emitter delegate
protocol StreamEmitterDelegate: AnyObject {

	/// Sends the given data on all of the clients streams
	///
	/// - Parameter data: Data to send
	func emit(data: Data)
}
