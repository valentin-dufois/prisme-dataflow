//
//  DataHolder.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 28/11/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

/// Holds the audio Data.
///
/// Provides convenient methods to emit them
class DataHolder {
	// ////////////////////
	// MARK: Singleton

	/// Hold the singleton instance
	private static var _instance:DataHolder?

	/// Extracted audio data
	var audioData = RecordingData()

	/// Mark init as private to prevent oustide init
	private init() { }

	/// get an instance of the engine. Instanciate it if needed.
	static var instance:DataHolder {
		get {
			guard _instance == nil else { return _instance! }

			_instance = DataHolder()
			return _instance!
		}
	}
}

// MARK: - Sending Data
extension DataHolder {
	/// Encode as JSON the stored audio data
	///
	/// - Returns: A JSON representation of the audioData property
	func asJSON() -> Data {
		// Transform audio Data to JSON
		let encoder = JSONEncoder()

		return try! encoder.encode(App.dataHolder.audioData)
	}
}
