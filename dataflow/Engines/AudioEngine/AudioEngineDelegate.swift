//
//  AudioEngineDelegate.swift
//  dataflow
//
//  Created by Valentin Dufois on 10/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import AudioKit

protocol AudioEngineDelegate: AnyObject {
	func audioEngine(_ engine: AudioEngine, hasRecordedBuffer buffer: AVAudioPCMBuffer)
}
