import Foundation
import CreateML

/// The Emotion Classifier Playground retrieve a CSV file containing emotion + phrase pairs.
/// The file is used to train a NaturalLanguageClassifier which is then saved to `modelSavePath`

/// The actual classifier
var emotionClassifier:MLTextClassifier?

/// Saving path for the generated model
let modelSavePath:String = "/Users/val/Projects/PRISME/dataflow/dataflow/Engines/AudioEngine/DataExtractors/EmotionClassifierModel.mlmodel"

// Start by loading the phrases
guard let url:URL = URL(string: "http://valentindufois.fr/prisme/emotion-classifier/phrases.csv") else { fatalError("Bad URL") }
var phrases:[String: String] = loadDataFrom(url)

// Build the data table
let phrasesData:[String: MLDataValueConvertible]! = [
	"emotion": phrases.map{$0.1},
	"phrase": phrases.map{$0.0}
]

let classificationData = try! MLDataTable(dictionary: phrasesData)

// Split the phrases in two
let (trainingData, testingData) = classificationData.randomSplit(by: 0.8, seed: 5)

// Set classifier parameter
var parameters = MLTextClassifier.ModelParameters()
parameters.validationData = testingData

// Build the classifier
emotionClassifier = try! MLTextClassifier(trainingData: trainingData, textColumn: "phrase", labelColumn: "emotion", parameters: parameters)

// Finally, save the model
let metadata = MLModelMetadata(author: "Valentin Dufois",
							   shortDescription: "A model trained to classify commom emotions.",
							   version: "1.0")

try emotionClassifier?.write(to: URL(fileURLWithPath: modelSavePath),
							  metadata: metadata)
