//
//  SpeechRecognizer.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 28/11/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import Speech

/// Performs speech recognition tasks
class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate {

	// //////////////////////////////
	// SPEECH RECOGNITION PROPERTIES

	/// The speech recognizer
	private let _speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-CA"))!

	/// The current recognition request
	private var _recognitionRequest: SFSpeechAudioBufferRecognitionRequest!

	/// The current recognition task
	private var _recognitionTask: SFSpeechRecognitionTask!

	// /////////////////
	// CLASS PROPERTIES

	/// Tells if the speech recognition is available
	private var _available:Bool = false

	/// Tells if the speech recognition is available
	var available: Bool { return _available }

	/// Tell if the SpeechRecognizer is runngin
	private var _running:Bool = false

	/// Used to detect end of phrases
	private var _silenceTimer:Timer!

	/// The recognition timer prevent running the recognition task for more than
	/// one minute, which is forbiden by the framework
	private var _recognitionTimer:Timer!

	/// The speechRecognizerDelegate
	private var _recognitionTaskDelegate: SpeechRecognizerTaskDelegate!

	/// Make sure weareauthorize to make speech recognition request, and init the delegate
	override init () {
		super.init()

		authorizeSpeechRecognition()

		// Create the recognition task delegate
		_recognitionTaskDelegate = SpeechRecognizerTaskDelegate()
		_recognitionTaskDelegate.recognizer = self
	}
}


// MARK: - Recognition task lifecycle
extension SpeechRecognizer {
	/// Create and configure the speech recognition request
	func makeRecognitionTask() {
		guard _running else { return }

		// Create a new request
		_recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
		_recognitionRequest.shouldReportPartialResults = true

		// Reset the audio data informations
		App.dataHolder.audioData.phrase = nil
		App.dataHolder.audioData.charactersCount = 0
		App.dataHolder.audioData.emotion = nil

		// Create a recognition task for the speech recognition session.
		// Keep a reference to the task so that it can be canceled.
		_recognitionTask = _speechRecognizer.recognitionTask(with: _recognitionRequest, delegate: _recognitionTaskDelegate)

		// Create a 55s timer to make sure we stay inside the allowed recognition window
		_recognitionTimer = Timer.scheduledTimer(withTimeInterval: 55, repeats: false, block: cancelRecognitionTask)
	}

	/// Start or restart the timer used to detect end of phrase silences
	func setWaitForEndOfPhrase() {
		_silenceTimer?.invalidate()
		_silenceTimer = nil
		_silenceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: endRecognitionTask)
	}

	/// Called when the recognition task ends
	func recognitionHasEnded() {
		_recognitionTimer?.invalidate()
		_silenceTimer?.invalidate()

		if(_running) {
			makeRecognitionTask()
		}
	}

	/// Stops the current recognition task
	///
	/// - Parameter timer: the timer who called the method
	@objc func endRecognitionTask(timer: Timer?) {
		_recognitionTask?.finish()
	}

	/// Cancel the current recognition task
	///
	/// - Parameter timer: the timer who called the method
	@objc func cancelRecognitionTask(timer: Timer?) {
		_recognitionTask?.cancel()
	}
}

// MARK: - Recognizer controls from outside
extension SpeechRecognizer {
	/// Start the recognizer engine
	func start() {
		guard _available else { return

		}
		_running = true
		makeRecognitionTask()
	}

	/// Pass the given audio buffer to the speech recognizer
	///
	/// - Parameter buffer: Audio buffer to analyse
	func analyze(_ buffer: AVAudioPCMBuffer) {
		guard _running else { return }

		_recognitionRequest.append(buffer)
	}

	/// Stops the recognizer engine
	func stop() {
		_running = false
		cancelRecognitionTask(timer: nil)
	}
}

// MARK: - User authorization
extension SpeechRecognizer {
	/// Request authorization from the user to make speech recognition tasks
	func authorizeSpeechRecognition() {
		// Set ourself as the speech recognizer delegate
		_speechRecognizer.delegate = self

		// Make the authorization request.
		SFSpeechRecognizer.requestAuthorization { authStatus in
			// Divert to the app's main thread so that the UI
			// can be updated.
			OperationQueue.main.addOperation {
				switch authStatus {
				case .authorized:
					self._available = true
				case .denied:
					print("User refused speech recognition")
				case .restricted:
					print("Speech recognition is not possible on this device")
				case .notDetermined:
					print("Speech recognition has not been authorized yet")
				}
			}
		}
	}
}
