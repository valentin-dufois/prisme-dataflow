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

	private var _mic: AKMicrophone!
	private var _booster: AKBooster!
	private var _frequencyTracker: AKFrequencyTracker!
	private var _inputTap: AKLazyTap!

	private var _engine: AVAudioEngine!
	private var _player: AVAudioPlayerNode!

	private var _audioFormat: AVAudioFormat

	var audioFormat: AVAudioFormat { return _audioFormat }

	// //////////////////////////
	// MARK: General porperties

	private var _inputTapTimer: Repeater!

	var isRunning: Bool { return _running }
	private var _running: Bool = false

	weak var delegate: AudioEngineDelegate?


	override init () {
		// Set AudioKit settings
		AKSettings.audioInputEnabled = true
		AKSettings.ioBufferDuration = 0.002

		// Create the chain
		_mic = AKMicrophone()
		_frequencyTracker = AKFrequencyTracker(_mic)
		_booster = AKBooster(_frequencyTracker, gain: 0)

		_inputTap = AKLazyTap(node: _mic.avAudioNode)

		// ~ Send the end of the chain to the output of AudioKit

		// Add the output chain
		_engine = AudioKit.engine
		_player = AVAudioPlayerNode()

		_audioFormat = _engine.inputNode.inputFormat(forBus: 0)

		AudioKit.output = AKMixer(AKNode(avAudioNode: _player), _booster)
	}


	func start() {
		// Make sure the engine isn't already running
		if isRunning {
			print("[AudioEngine.start] Engine is already running")
			return
		}

		// Start AudioKit and the player
		do {
			try AudioKit.start()
			_player?.play()
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

	func stop() {
		guard isRunning else {
			print(")[AudioEngine.stop] Engine isn't running")
			return
		}

		_inputTapTimer?.pause()

		do {
			try AudioKit.stop()
			_player?.stop()
		} catch {
			fatalError("[AudioEngine.stop] Could not properly stop AudioKit : \(error.localizedDescription)")
		}

		_running = false
	}

	deinit {
		// Stop the engine if its running
		stop()

		// Clean the repeater
		_inputTapTimer?.removeAllObservers()

		// Detach audio chain components
		_booster?.detach()
		_frequencyTracker?.detach()
		AudioKit.output = nil
	}
}

// MARK: - Informations and buffers inputs (from the mic)
extension AudioEngine {
	private func inputTapObserver() {
		// Get the audio buffer
		let audioBuffer = AVAudioPCMBuffer(pcmFormat: _mic.avAudioNode.outputFormat(forBus: 0), frameCapacity: 44100)!
		_inputTap.fillNextBuffer(audioBuffer, timeStamp: nil)

		// Make sure there is audio data to work with
		guard audioBuffer.frameLength > 0 else { return }

		// Call the delegate
		delegate?.audioEngine(self, hasRecordedBuffer: audioBuffer)
	}

	var frequency: Double? { return _frequencyTracker?.frequency }
	var amplitude: Double? { return _frequencyTracker?.amplitude }
}


// MARK: - Buffer input (to play)
extension AudioEngine {
	func play(buffer: AVAudioPCMBuffer) {
		print("PlAYING")
		_player.scheduleBuffer(buffer, completionHandler: nil)
	}
}
