//
//  EmotionClassifier.swift
//  
//
//  Created by Valentin Dufois on 07/12/2018.
//

import Foundation
import NaturalLanguage

/// Uses the `EmotionClassifierModel` to classify given phrases
class EmotionClassifier {
	/// The Natural Language Model
	private var _model: NLModel

	/// Loads the classifier model
	init() {
		_model = try! NLModel(mlModel: EmotionClassifierModel().model)
	}

	/// Analyze and classify the given phrase
	///
	/// - Parameter phrase: The phrase to classify
	/// - Returns: The associated emotion determined for the given phrase
	func analyze(phrase: String) -> String {
		return _model.predictedLabel(for: phrase) ?? "Neutre"
	}
}
