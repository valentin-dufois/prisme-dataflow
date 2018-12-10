//
//  AudioEngine.swift
//  dataflow
//
//  Created by Valentin Dufois on 10/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import AudioKit
import Repeat

class AudioEngine: NSObject {

	// //////////////////////////
	// MARK: AudioKit & AVAudioEngine properties

	/// The microphone
	internal let _mic: AKMicrophone

	/// Silence to prevent the mic from outputing to the speakers
	internal let _silence: AKBooster

	/// Frequencty tracker for the mic
	internal let _frequencyTracker: AKFrequencyTracker

	/// Input tap attached to the mic
	internal let _inputTap: AKLazyTap

	/// Reference to the audio engine — Managed by AudioKit
	internal let _engine: AVAudioEngine

	/// The player node used to send audio data to the speakers
	internal let _player: AVAudioPlayerNode

	/// The audio format used by the engine
	var audioFormat: AVAudioFormat { return AudioKit.format }

	// //////////////////////////
	// MARK: General porperties

	/// Timer used to trigger the input tap
	private var _inputTapTimer: Repeater!

	/// Tell if the engine is currently running
	var isRunning: Bool { return _running }
	private var _running: Bool = false

	/// The AudioEngine delegate
	weak var delegate: AudioEngineDelegate?


	/// Create the Input and Output chain without starting it
	override init () {
		// Set AudioKit settings
		AKSettings.audioInputEnabled = true
		AKSettings.ioBufferDuration = 0.002

		// Create the chain
		_mic = AKMicrophone()
		_frequencyTracker = AKFrequencyTracker(_mic)
		_silence = AKBooster(_frequencyTracker, gain: 0)

		_inputTap = AKLazyTap(node: _mic.avAudioNode)!

		// ~ Send the end of the chain to the output of AudioKit

		// Add the output chain
		_engine = AudioKit.engine
		_player = AVAudioPlayerNode()

		AudioKit.output = AKMixer(AKNode(avAudioNode: _player), _silence)
	}


	/// Start the engine, effectively recording from the mic and playing on the speaker
	func start() {
		// Make sure the engine isn't already running
		if isRunning {
			print("[AudioEngine.start] Engine is already running")
			return
		}

		// Start AudioKit and the player
		do {
			try AudioKit.start()
			_player.play()
		} catch {
			fatalError("[AudioEngine.start] Couldn't start AudioKit : \(error.localizedDescription)")
		}

		// if it doesn't exist, create the input tap timer
		if(_inputTapTimer == nil) {
			_inputTapTimer = Repeater(interval: .seconds(AKSettings.ioBufferDuration / 2)) {
				[weak self] timer in
				self?.inputTapObserver()
			}
		}

		// Start the input tap observer
		_inputTapTimer.start()

		_running = true
	}

	/// Stop the engine
	func stop() {
		guard isRunning else {
			print(")[AudioEngine.stop] Engine isn't running")
			return
		}

		_inputTapTimer?.pause()

		do {
			try AudioKit.stop()
			_player.stop()
		} catch {
			fatalError("[AudioEngine.stop] Could not properly stop AudioKit : \(error.localizedDescription)")
		}

		_running = false
	}

	/// Properly free used resources
	deinit {
		// Stop the engine if its running
		stop()

		// Clean the repeater
		_inputTapTimer?.removeAllObservers()

		// Detach audio chain components
		_silence.detach()
		_frequencyTracker.detach()
		AudioKit.output = nil
	}
}

// MARK: - Informations and buffers inputs (from the mic)
extension AudioEngine {
	/// Called continuously while the engine is running.
	///
	/// Gets the current buffer and send it to the delegate
	internal func inputTapObserver() {
		// Get the audio buffer
		let audioBuffer = AVAudioPCMBuffer(pcmFormat: _mic.avAudioNode.outputFormat(forBus: 0), frameCapacity: 44100)!
		_inputTap.fillNextBuffer(audioBuffer, timeStamp: nil)

		// Make sure there is audio data to work with
		guard audioBuffer.frameLength > 0 else { return }

		// Call the delegate
		delegate?.audioEngine(self, hasRecordedBuffer: audioBuffer)
	}

	/// The current input frequency
	var frequency: Double { return _frequencyTracker.frequency }

	/// The current input amplitude
	var amplitude: Double { return _frequencyTracker.amplitude }
}


// MARK: - Buffer input (to play)
extension AudioEngine {
	/// Schedule the given audio buffer to play
	///
	/// - Parameter buffer: Audio buffer to play
	func play(buffer: AVAudioPCMBuffer) {
		_player.scheduleBuffer(buffer, completionHandler: nil)
	}
}
