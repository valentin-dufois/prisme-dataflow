//
//  NativeAudioEngine.swift
//  dataflow
//
//  Created by Dev on 2018-12-09.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import AVFoundation
import Repeat

class NativeAudioEngine: NSObject {
    
    private var _audioEngine:AVAudioEngine!
    internal var _audioFormat: AVAudioFormat!
    
    private var _inputNode: AVAudioInputNode!
    internal var _playerNode: AVAudioPlayerNode!
    
    weak var delegate: NativeAudioEngineDelegate?
    
    override init () {
        _audioEngine = AVAudioEngine()
    
        _inputNode = _audioEngine.inputNode
        _playerNode = AVAudioPlayerNode()
        
        _audioFormat = _inputNode.inputFormat(forBus: 0)
        
        _audioEngine.attach(_playerNode)
        _audioEngine.connect(_playerNode, to: _audioEngine.mainMixerNode, format: _audioFormat)
        
        _audioEngine.prepare()
    }
    
    func start () {
//        _inputNode.installTap(onBus: 0, bufferSize: 44100, format: _audioFormat, block: inputAudioTap)
        
        try! _audioEngine.start()
        _playerNode.play()
    }
    
    func end() {
        _audioEngine.stop()
        _playerNode.stop()
    }
    
    deinit {
        end()
    }
}

// MARK: - Getting and Playing audio
extension NativeAudioEngine {
    private func inputAudioTap(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        // Make sure there is audio data to work with
        guard buffer.frameLength > 0 else { return }
        
        // Call the delegate with the buffer
        delegate?.audioEngine(self, inputBuffer: buffer)
    }
    
    func play(buffer: AVAudioPCMBuffer) {
        _playerNode.scheduleBuffer(buffer, completionHandler: nil)
    }
}
