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
	private var _emotionClassifier = EmotionClassifier()

	/// Called when a hypothesized transcription is available.
	///
	/// - Parameters:
	///   - task: The current task
	///   - transcription: The transcription inferred
	func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
		App.dataHolder.audioData.phrase = transcription.formattedString
		App.dataHolder.audioData.charactersCount = transcription.formattedString.count
		App.dataHolder.audioData.emotion = _emotionClassifier.analyze(phrase: App.dataHolder.audioData.phrase!)

		recognizer?.setWaitForEndOfPhrase()
	}

	///  Called when the final utterance is recognized.
	///
	/// - Parameters:
	///   - task: The current task
	///   - transcription: The transcription inferred
	func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition transcriptionResult: SFSpeechRecognitionResult) {
		App.dataHolder.audioData.phrase = transcriptionResult.bestTranscription.formattedString

		recognizer?.recognitionHasEnded();
	}

	///  Called that the task has been canceled.
	///
	/// - Parameter task: The current task
	func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
		recognizer?.recognitionHasEnded();
	}
}
