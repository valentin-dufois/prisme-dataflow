//
//  EmotionClassifier.swift
//  
//
//  Created by Valentin Dufois on 07/12/2018.
//

import Foundation
import NaturalLanguage

class EmotionClassifier {
	private var _model: NLModel

	init() {
		_model = try! NLModel(mlModel: EmotionClassifierModel().model)
	}

	func analyze(phrase: String) -> String {
		return _model.predictedLabel(for: phrase) ?? "Neutre"
	}
}
