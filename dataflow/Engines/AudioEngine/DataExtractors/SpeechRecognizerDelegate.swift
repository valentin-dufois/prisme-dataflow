//
//  SpeechrecognizerDelegate.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 01/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import Speech

class SpeechRecognizerTaskDelegate: NSObject, SFSpeechRecognitionTaskDelegate {
	weak var recognizer: SpeechRecognizer!

	/// Called when a hypothesized transcription is available.
	///
	/// - Parameters:
	///   - task: The current task
	///   - transcription: The transcription inferred
	func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
		App.dataHolder.audioData.phrase = transcription.formattedString

		recognizer?.setWaitForEndOfPhrase()
	}

	///  Called when the final utterance is recognized.
	///
	/// - Parameters:
	///   - task: The current task
	///   - transcription: The transcription inferred
	func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition transcriptionResult: SFSpeechRecognitionResult) {
		App.dataHolder.audioData.phrase = transcriptionResult.bestTranscription.formattedString

		print(App.dataHolder.audioData.phrase ?? "")

		recognizer?.recognitionHasEnded();
	}

	///  Called that the task has been canceled.
	///
	/// - Parameter task: The current task
	func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
		recognizer?.recognitionHasEnded();
	}
}
