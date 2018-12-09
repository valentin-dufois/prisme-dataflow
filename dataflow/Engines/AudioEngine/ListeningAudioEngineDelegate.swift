//
//  ListeningAudioEngineDelegate.swift
//  dataflow
//
//  Created by Valentin Dufois on 09/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import AVFoundation

/// The delegate used by the `ListeningAudioEngine` to pass its audio buffers
protocol ListeningAudioEngineDelegate: AnyObject {
	/// Called every time the listening engine has an audio buffer to pass
	///
	/// - Parameters:
	///   - listeningAudioEngine: The current ListeningAudioEngine
	///   - buffer: The audio buffer
	func audioEngine(_ listeningAudioEngine: ListeningAudioEngine, hasBuffer buffer: AVAudioPCMBuffer)
}
