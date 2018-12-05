//
//  ViewController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 28/11/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import UIKit
import AudioKit

class EmitterController: UIViewController {

	// ////////
	// MARK : OUTLETS
	@IBOutlet var startStopBtn: UIBarButtonItem!
	
	@IBOutlet var connectionStateLabel: UIBarButtonItem!
	
	@IBOutlet var decodedWordLabel: UILabel!
	@IBOutlet var audioFrequencyLabel: UILabel!
	@IBOutlet var decodedEmotionLabel: UILabel!
	@IBOutlet var audioAmplitudeLabel: UILabel!


	// //////////////////
	// MARK : PROPERTIES

	private var _mic: AKMicrophone!
	private var _silence: AKBooster!

	private var _recording: Bool = false
	private var _tap: AKLazyTap!
	private var _buffer: AVAudioPCMBuffer!

	// Data extractors

	private var _tracker: AKFrequencyTracker!
	private var _speechRecognizer: SpeechRecognizer = SpeechRecognizer()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Configure our audio session
		do {
			try initAudioSession()
		} catch {
			fatalError("Could not start recording : \(error.localizedDescription)")
		}

		NotificationCenter.default.addObserver(self, selector: #selector(onSocketConnected), name: Notifications.socketConnected.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(onSocketDisconnected), name: Notifications.socketDisconnected.name, object: nil)

		App.communicator.start()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}


	@IBAction func toggleRecording(_ sender: UIBarButtonItem) {
		if(_recording) {
			// Stop audio session
			endRecording()
			startStopBtn.title = "Start"
		} else {
			// Start audio session
			startRecording()
			startStopBtn.title = "Stop"
		}
	}

	@IBAction func reconnectToSocket(_ sender: Any) {
		App.communicator.reconnectToSocket()
	}
	

	/// Initialize the audio session
	///
	/// - Throws: in case of errors while setting things up
	private func initAudioSession() throws {
		AKSettings.audioInputEnabled = true
		AKSettings.ioBufferDuration = 0.002
		_mic = AKMicrophone()
		_tracker = AKFrequencyTracker(_mic)
		_silence = AKBooster(_tracker, gain: 0)

		_tap = AKLazyTap(node: _mic.avAudioNode)
		_buffer = AVAudioPCMBuffer(pcmFormat: _mic.avAudioNode.outputFormat(forBus: 0), frameCapacity: 44100)
	}

	private func startRecording() {
		AudioKit.output = _silence

		// Start audiokit
		do {
			try AudioKit.start()
		} catch {
			fatalError("Could not start audio engine : \(error.localizedDescription)")
		}

		// Add a timer for each buffer
		Timer.scheduledTimer(timeInterval: AKSettings.ioBufferDuration / 2,
							 target: self,
							 selector: #selector(audioObserver),
							 userInfo: nil,
							 repeats: true)

		_recording = true

		// Start the speech recognizer
		_speechRecognizer.start()
	}

	private func endRecording() {
		// Stop the engine
		_speechRecognizer.stop()

		do {
			try AudioKit.stop()
		} catch {
			fatalError("Error while stopping AudioKit : \(error.localizedDescription)")
		}

		_recording = false
	}

	deinit {
		if(_recording) {
			endRecording()
		}

		App.communicator.deconnectFromSocket()
	}
}

// MARK: - Information extraction from the audio feed
extension EmitterController {
	@objc func audioObserver() {
		// Get audio buffer
		_tap.fillNextBuffer(_buffer, timeStamp: nil)

		// Make sure there is audio data to work with
		guard _buffer.frameLength > 0 else { return }

		// Frequency
		audioFrequencyLabel.text = "\((_tracker.frequency * 100).rounded() / 100) hz"
		App.dataHolder.audioData.frequency = _tracker.frequency

		// Amplitude
		audioAmplitudeLabel.text = "\((_tracker.amplitude * 100).rounded() / 100)"
		App.dataHolder.audioData.amplitude = _tracker.amplitude

		// Speech
		_speechRecognizer.analyze(_buffer)
		decodedWordLabel.text = App.dataHolder.audioData.phrase ?? "-"

		App.dataHolder.emmit()

		// Finally, send the buffer to any receiver
		// Array(UnsafeBufferPointer(start: _buffer.floatChannelData![0], count: Int(_buffer.frameLength))

	}
}


// MARK: - Observers
extension EmitterController {
	@objc func onSocketConnected() {
		connectionStateLabel.title = "ONLINE"
	}

	@objc func onSocketDisconnected() {
		connectionStateLabel.title = "OFFLINE"
	}
}
