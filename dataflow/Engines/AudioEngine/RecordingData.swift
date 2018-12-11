//
//  ExtractedAudioData.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 28/11/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

struct RecordingData: Codable {
	var phrase:String?
	var charactersCount: Int = 0
	var emotion:String?
	var frequency:Double = 0
	var amplitude:Double = 0
}
