//
//  ExtractedAudioData.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 28/11/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

/// Structure holding the extracted informations from the audioInput
struct RecordingData: Codable {
	/// The spoken phrase, if any
	var phrase:String?

	/// The number of characters spoken
	var charactersCount: Int = 0

	/// Which emotion has been determined, no emotion means neutral
	var emotion:String?

	/// The instant frequency of the audio
	var frequency:Double = 0

	/// The instant amplitude of the audio
	var amplitude:Double = 0
}
