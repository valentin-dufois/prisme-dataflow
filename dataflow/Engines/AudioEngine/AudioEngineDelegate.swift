//
//  AudioEngineDelegate.swift
//  dataflow
//
//  Created by Valentin Dufois on 10/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import AVFoundation

/// The audioEngineDelegate, used for tapping on the input feed from the mic
protocol AudioEngineDelegate: AnyObject {
	/// Called continuously while the engine is running
	///
	/// Any computing heavy done in this method should be sent to another queue
	///
	/// - Parameters:
	///   - engine: The audio engine
	///   - buffer: Input audio buffer
	func audioEngine(_ engine: AudioEngine, hasRecordedBuffer buffer: AVAudioPCMBuffer)
}
