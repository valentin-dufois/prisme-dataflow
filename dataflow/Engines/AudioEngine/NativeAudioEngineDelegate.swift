//
//  NativeAudioEngineDelegate.swift
//  dataflow
//
//  Created by Dev on 2018-12-09.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import AVFoundation

protocol NativeAudioEngineDelegate: AnyObject {
    func audioEngine(_ engine: NativeAudioEngine, inputBuffer buffer: AVAudioPCMBuffer)
}
