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

	// ///////////////
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

	// Data extractors
	private var _tracker: AKFrequencyTracker!
	private var _speechRecognizer: SpeechRecognizer = SpeechRecognizer()

	// Stream delegate
	var emitterStream: streamEmitterDelegate?

	// The socket for sending data
	private var _socket:Socket!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Configure our audio session
		initAudioSession()

		// Configure the socket
		_socket = Socket()
		_socket.delegate = self
		_socket.connect(to: DataFlowDefaults.serverURL.url!.absoluteString,
						port: Int32(DataFlowDefaults.serverPort.integer!))
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

	/// Stop and restart the socket connection
	///
	/// - Parameter sender: The ONLINE/OFFLINE button
	@IBAction func reconnectToSocket(_ sender: Any) {
		_socket.reconnect()
	}

	/// Properly end any ongoing recording
	deinit {
		endRecording()
		_socket?.disconnect()
	}
}


// MARK: - Audio management methods
extension EmitterController {

	/// Initialize the audio session
	///
	/// - Throws: in case of errors while setting things up
	private func initAudioSession() {
		AKSettings.audioInputEnabled = true
		AKSettings.ioBufferDuration = 0.002

		_mic = AKMicrophone()
		_tracker = AKFrequencyTracker(_mic)
		_silence = AKBooster(_tracker, gain: 0)

		_tap = AKLazyTap(node: _mic.avAudioNode)
	}

	/// Start the recording, create the loop and start the speech recognizer
	private func startRecording() {
		guard !_recording else {
			print("[EmitterController.startRecording] A recording is already started")
			return
		}

		AudioKit.output = _silence

		// Start audiokit
		do {
			try AudioKit.start()
		} catch {
			fatalError("[EmitterController.startRecording] Error while starting AudioKit : \(error.localizedDescription)")
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

	/// Called on every audio buffer, extract informations and emit data
	@objc func audioObserver() {
		// Get the audio buffer
		let buffer = AVAudioPCMBuffer(pcmFormat: _mic.avAudioNode.outputFormat(forBus: 0), frameCapacity: 44100)!
		_tap.fillNextBuffer(buffer, timeStamp: nil)

		// Make sure there is audio data to work with
		guard buffer.frameLength > 0 else { return }

		// Execute audio analysis queue asynchronously to improve performances
		App.audioAnalysisQueue.async {
			// Frequency
			App.dataHolder.audioData.frequency = self._tracker.frequency

			// Amplitude
			App.dataHolder.audioData.amplitude = self._tracker.amplitude

			// Speech
			self._speechRecognizer.analyze(buffer)

			// Finally, send the data to the socket
			self._socket.emit(data: App.dataHolder.asJSON())

			// And send to the stream
			self.emitterStream?.emit(data: buffer.toData())
		}

		// Update the UI on the main thread. Latency is't important as these labels
		// serves only as low precision indicators
		audioFrequencyLabel.text = "\((App.dataHolder.audioData.frequency * 100).rounded() / 100) hz"
		audioAmplitudeLabel.text = "\((App.dataHolder.audioData.amplitude * 100).rounded() / 100)"
		decodedWordLabel.text = App.dataHolder.audioData.phrase ?? "-"
	}

	/// Properly ends the recording and links systems
	private func endRecording() {
		guard _recording else {
			print("[EmitterController.endRecording] There is no recording to end")
			return
		}

		// Stop the engine
		_speechRecognizer.stop()

		do {
			try AudioKit.stop()
		} catch {
			fatalError("[EmitterController.endRecording] Error while stopping AudioKit : \(error.localizedDescription)")
		}

		_recording = false
	}
}


// MARK: - Socket delegate
extension EmitterController: SocketDelegate {

	/// Called when the socket succesfully connect
	///
	/// - Parameter _: The socket
	func socketDidConnect(_ socket: Socket) {
		connectionStateLabel.title = "ONLINE"
	}

	/// Called when the socked gets disconnected, either by a call to `Socket.disconnect`
	/// or 'Socket.reconnect()` or if the connection gets lost.
	///
	/// - Parameters:
	///   - socket: The current socket
	///   - error: The error if any
	func socketDidDisconnect(_ socket: Socket, error: Error?) {
		if let error = error {
			print("Socket error: \(error.localizedDescription)")
		}
		connectionStateLabel.title = "OFFLINE"
	}
}
