//
//  ViewController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 28/11/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import UIKit
import AVFoundation

/// The view shown on the emitter end on the Emitter tab
class EmitterController: UIViewController {

	// ///////////////
	// MARK : OUTLETS

	/// The audio start and stop button
	@IBOutlet var startStopBtn: UIBarButtonItem!
	
	/// The socket connection state label
	@IBOutlet var connectionStateLabel: UIBarButtonItem!
	
	/// The decoded phrase label
	@IBOutlet var decodedPhraseLabel: UITextView!

	/// The label showing the number of letters in the decoded phrase
	@IBOutlet var numberOfLettersLabel :UILabel!

	/// The label showing the frequency of the audio stream
	@IBOutlet var audioFrequencyLabel: UILabel!

	/// The label showing the decoded emotion of the audiostream
	@IBOutlet var decodedEmotionLabel: UILabel!

	/// The label showing the amplitude of the audio stream
	@IBOutlet var audioAmplitudeLabel: UILabel!


	// //////////////////
	// MARK : PROPERTIES

	/// Data extractors
	private var _speechRecognizer: SpeechRecognizer!

	/// The socket for sending data
	private var _socket:Socket!

	/// Called when the view loads
	override func viewDidLoad() {
		super.viewDidLoad()

		// Configure our audio session
		App.audioEngine.delegate = self
		App.audioEngine.setAutoRestart(every: 240)

		// Get a speech recognizer
		_speechRecognizer = SpeechRecognizer()

		// Configure the socket
		_socket = Socket()
		_socket.delegate = self
		_socket.connect(to: DataFlowDefaults.serverURL.url!.absoluteString,
						port: Int32(DataFlowDefaults.serverPort.integer!))
	}

	/// Called every time the view is shown
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
			NotificationCenter.default.post(name: Notifications.stoppedPlaying.name, object: nil)
			return
		}

		// Start audio session
		startRecording()
		startStopBtn.title = "Stop"
		NotificationCenter.default.post(name: Notifications.startedPlaying.name, object: nil)
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
			App.dataHolder.audioData.frequency = App.audioEngine.frequency

			// Amplitude
			App.dataHolder.audioData.amplitude = App.audioEngine.amplitude

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
            self.decodedPhraseLabel.text = App.dataHolder.audioData.phrase ?? ""
            self.numberOfLettersLabel.text = "\(App.dataHolder.audioData.charactersCount)"

			let emotionID = Int(App.dataHolder.audioData.emotion ?? "0")
			let emotionLabel:String!

			switch emotionID {
			case 1: emotionLabel = "Interest"
			case 2: emotionLabel = "Contrariety"
			case 3: emotionLabel = "Boredom"
			case 4: emotionLabel = "Reverie"
			case 5: emotionLabel = "Distraction"
			case 6: emotionLabel = "Apprehension"
			case 7: emotionLabel = "Resignation"
			case 8: emotionLabel = "Serenity"
			default: emotionLabel = "Neutral"
			}

            self.decodedEmotionLabel.text = emotionLabel
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
