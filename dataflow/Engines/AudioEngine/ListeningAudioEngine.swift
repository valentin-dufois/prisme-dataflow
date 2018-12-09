//
//  ListeningAudioEngine.swift
//  dataflow
//
//  Created by Valentin Dufois on 09/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import AudioKit

class ListeningAudioEngine:NSObject {

	// ///////////////////
	// MARK: AUDIO PROPERTIES

	private var _mic: AKMicrophone!
	private var _booster: AKBooster!
	private var _frequencyTracker: AKFrequencyTracker!
	private var _tap: AKLazyTap!

	private var _listeningTimer: Timer?
	private var _running: Bool = false

	weak var delegate: ListeningAudioEngineDelegate?

	var isRunning: Bool { return _running }

	/// Will set up and create all the required object to listen
	override init() {
		// Set AudioKit settings
		AKSettings.audioInputEnabled = true
		AKSettings.ioBufferDuration = 0.002

		// Create the chain
		_mic = AKMicrophone()
		_frequencyTracker = AKFrequencyTracker(_mic)
		_booster = AKBooster(_frequencyTracker, gain: DataFlowDefaults.audioGain.double!)
		_tap = AKLazyTap(node: _mic.avAudioNode)

		// ~ Send the end of the chain to the output of AudioKit
		AudioKit.output = _booster
	}

	/// Starts listening
	func start() {
		// Make sure the engine isn't already running
		if _running {
			print("[ListeningAudioEngine.start] Engine is already running")
			return
		}

		// Start AudioKit
		do {
			try AudioKit.start()
		} catch {
			fatalError("[ListeningAudioEngine.start] Couldn't start AudioKit  \(error.localizedDescription)")
		}

		// Create a timer for the tap
		_listeningTimer = Timer.scheduledTimer(timeInterval: AKSettings.ioBufferDuration / 2,
							 target: self,
							 selector: #selector(listeningTap),
							 userInfo: nil,
							 repeats: true)

		_running = true
	}

	/// Called by the timer, gets the audio buffer, makes sure it is full,
	/// then call the delegate
	@objc private func listeningTap() {
		let audioBuffer = AVAudioPCMBuffer(pcmFormat: _mic.avAudioNode.outputFormat(forBus: 0), frameCapacity: 44100)!
		_tap.fillNextBuffer(audioBuffer, timeStamp: nil)

		// Make sure there is audio data to work with
		guard audioBuffer.frameLength > 0 else { return }

		// Call the delegate
		delegate?.audioEngine(self, hasBuffer: audioBuffer)
	}

	/// Stop the listening engine. The engine CAN be started again after calling
	/// this method.
	func stop() {
		guard _running else {
			print("[ListeningAudioEngine.stop] Engine isn't running")
			return
		}

		// Stop the listening timer
		_listeningTimer?.invalidate()

		// Stop Audiokit
		do {
			try AudioKit.stop()
		} catch {
			fatalError("[ListeningAudioEngine.stop] Couln't stop AudioKit : \(error.localizedDescription)")
		}

		_running = false
	}

	/// Make sure we end gracefully
	deinit {
		// Stop the engine if its running
		stop()

		// Detach audio chain components
		_booster?.detach()
		_frequencyTracker?.detach()
		AudioKit.output = nil
	}

	var frequency: Double? { return _frequencyTracker?.frequency }
	var amplitude: Double? { return _frequencyTracker?.amplitude }
}
