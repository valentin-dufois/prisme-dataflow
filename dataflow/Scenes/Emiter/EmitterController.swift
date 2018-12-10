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
	
	@IBOutlet var decodedWordLabel: UITextView!
	@IBOutlet var numberOfLetterLabel :UILabel!
	@IBOutlet var audioFrequencyLabel: UILabel!
	@IBOutlet var decodedEmotionLabel: UILabel!
	@IBOutlet var audioAmplitudeLabel: UILabel!


	// //////////////////
	// MARK : PROPERTIES

	// Data extractors
	private var _speechRecognizer: SpeechRecognizer!

	// The socket for sending data
	private var _socket:Socket!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Configure our audio session
		App.audioEngine.delegate = self

		// Get a speech recognizer
		_speechRecognizer = SpeechRecognizer()

		// Configure the socket
		_socket = Socket()
		_socket.delegate = self
		_socket.connect(to: DataFlowDefaults.serverURL.url!.absoluteString,
						port: Int32(DataFlowDefaults.serverPort.integer!))
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Make sur the emitter is started
		App.emitterStream!.initMultipeer()
	}

	/// Starts or stop the recording
	///
	/// Does not affect the socket nor the streams
	///
	/// - Parameter sender: The start/Stop button
	@IBAction func toggleRecording(_ sender: UIBarButtonItem) {
		if(App.audioEngine.isRunning) {
			// Stop audio session
			endRecording()
			startStopBtn.title = "Start"
			return
		}

		// Start audio session
		startRecording()
		startStopBtn.title = "Stop"
	}

	/// Stop and restart the socket connection
	///
	/// - Parameter sender: The ONLINE/OFFLINE button
	@IBAction func reconnectToSocket(_ sender: Any) {
		_socket.reconnect()
	}

	/// Properly end any ongoing recording
	deinit {
        print("[EmitterController.deinit]")
		endRecording()
		_socket?.disconnect()
	}
}


// MARK: - Recording lifecycle
extension EmitterController {

	/// Start listening and start the speech recognizer
	private func startRecording() {
		guard !App.audioEngine.isRunning else {
			print("[EmitterController.startRecording] A recording is already started")
			return
		}

		App.audioEngine.start()

		// Start the speech recognizer
		_speechRecognizer.start()
	}

	/// Properly ends the recording and links systems
	private func endRecording() {
		guard (App.audioEngine.isRunning) else {
			print("[EmitterController.endRecording] There is no recording to end")
			return
		}

		// Stop the speech recognizer
		_speechRecognizer.stop()

		// Stop the listening engine
		App.audioEngine.stop()
	}
}



// MARK: - ListeningAudioEngineDelegate
extension EmitterController: AudioEngineDelegate {
	/// Called on every audio buffer, extract informations and emit data
	///
	/// - Parameters:
	///   - listeningAudioEngine: The listening engine sending the event
	///   - buffer: The audio buffer
	func audioEngine(_ engine: AudioEngine, hasRecordedBuffer buffer: AVAudioPCMBuffer) {
		// Execute audio analysis queue asynchronously to improve performances
		App.audioAnalysisQueue.async {
			// Frequency
			App.dataHolder.audioData.frequency = App.audioEngine.frequency!

			// Amplitude
			App.dataHolder.audioData.amplitude = App.audioEngine.amplitude!

			// Speech
			self._speechRecognizer.analyze(buffer)

			// Finally, send the data to the socket
			self._socket.emit(data: App.dataHolder.asJSON())

			// And send to the stream
			//            print("Emitting to stream")
			App.emitterStream?.emit(data: buffer.toData())
		}

		// Update the UI on the main thread. Latency is't important as these labels
		// serves only as low precision indicators
        DispatchQueue.main.async {
            self.audioFrequencyLabel.text = "\((App.dataHolder.audioData.frequency * 100).rounded() / 100) hz"
            self.audioAmplitudeLabel.text = "\((App.dataHolder.audioData.amplitude * 100).rounded() / 100)"
            self.decodedWordLabel.text = App.dataHolder.audioData.phrase ?? ""
            self.numberOfLetterLabel.text = "\(App.dataHolder.audioData.caracterCount)"
            self.decodedEmotionLabel.text = App.dataHolder.audioData.emotion ?? "neutral"
        }
	}
}


// MARK: - SocketDelegate
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
