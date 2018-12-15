//
//  App.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 04/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

/// Holds static properties to used from anywhere in the app.
///
/// Prevent overuse of the singleton pattern by simulating a global object
struct App {
	/// Holds the audio Data.
	///
	/// Provides convenient methods to emit them
	static let dataHolder = DataHolder.instance

	/// Stores a reference the Queue used for audio Analysis treatements
	static var audioAnalysisQueue = DispatchQueue(label: "prisme.dataflow.audioAnalysis", qos: DispatchQoS.utility)

	/// The current emitter stream, if any
    weak static var emitterStream: EmitterStreamController?
    
	/// The audio engine used by the app
    static var audioEngine: AudioEngine = AudioEngine()
}
