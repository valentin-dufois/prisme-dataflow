//
//  AudioStreamReader.swift
//  dataflow
//
//  Created by Dev on 2018-12-06.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import AVFoundation
import MultipeerConnectivity

class AudioStreamReader: NSObject {
    
    // /////////////////
    // MARK: Properties
    
    internal var _inputStream: InputStream?
    
    func read(stream:InputStream) {
        _inputStream = stream
        _inputStream!.delegate = self
        _inputStream!.open()
        
        App.audioAnalysisQueue.async {
            self._inputStream!.schedule(in: .current, forMode: .common)
            RunLoop.current.run()
        }
    
        print("AudioStreamReceiver started")
        
        NotificationCenter.default.addObserver(forName: Notifications.debug.name, object: nil, queue: nil) { notification in
            print(self._inputStream!.hasBytesAvailable)
            print(self._inputStream!.streamError)
        }
    }
    
    func end() {
        print("stopping AudioStreamReceiver")
        _inputStream?.close()
    }
    
    deinit {
        print("Deiniting AudioStreamReceiver")
    }
}

extension AudioStreamReader: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        print("STREAM EVENT : \(eventCode)")
        switch eventCode {
        case .hasBytesAvailable:
            pollStream()
        case .endEncountered:
            end()
        default: break
        }
    }
    
    @objc func pollStream() {
        guard let inputStream = _inputStream else {
            print("[AudioStreamReader.pollStream] There is no stream to poll")
            return
        }
        
        guard inputStream.hasBytesAvailable else {
            print("[AudioStreamReader.pollStream] Stream has nothing to read")
            return
        }
        
        print("Polling stream")
        
        let inputData = Data(reading: inputStream)
        let audioBuffer = AVAudioPCMBuffer(data: inputData, audioFormat: AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!)!
        
        print(audioBuffer.frameLength)
        
        
    }
}
