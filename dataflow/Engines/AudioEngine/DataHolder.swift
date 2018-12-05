//
//  DataHolder.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 28/11/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

class DataHolder {
	// ////////////////////
	// MARK: Singleton

	/// Hold the singleton instance
	private static var _instance:DataHolder?

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

	var audioData = RecordingData()
}

// MARK: - Sending Data
extension DataHolder {
	func emmit() {
		// Transform audio Data to JSON
		let encoder = JSONEncoder()

		App.communicator.emitToSocket(data: try! encoder.encode(App.dataHolder.audioData))
	}
}
