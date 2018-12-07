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
    
    // //////////////////////////////
    // MARK: Input stream properties

    internal var _inputStream: InputStream?
	internal var _timer: Timer?

	// //////////////////////////////
	// MARK: Audio player properties

	internal var _audioEngine = AVAudioEngine()
	internal var _playerNode = AVAudioPlayerNode()
	internal var _audioInput: AVAudioInputNode!
	internal var _audioFormat: AVAudioFormat!

	override init() {
		_audioInput = _audioEngine.inputNode
		_audioEngine.attach(_playerNode)
		_audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)

		_audioEngine.connect(_playerNode, to: _audioEngine.mainMixerNode, format: _audioFormat)

		_audioEngine.prepare()
	}

    func read(stream:InputStream) {
        _inputStream = stream
        _inputStream!.delegate = self

		self._inputStream!.schedule(in: .current, forMode: .common)

		try! _audioEngine.start()

		DispatchQueue.main.async {
			dispatchPrecondition(condition: .onQueue(.main))
			self._timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.pollStream), userInfo: nil, repeats: true)

			self._inputStream!.open()

			print("Stream scheduled")
		}

		// DEBUG
        NotificationCenter.default.addObserver(forName: Notifications.debug.name, object: nil, queue: nil) { notification in
            print(self._inputStream!.hasBytesAvailable)
			print(self._inputStream!.streamError as Any)
			self._timer?.fire()
        }
    }
    
    func end() {
        print("stopping AudioStreamReceiver")
        _inputStream?.close()
		_timer?.invalidate()

		_audioEngine.stop()
		_playerNode.stop()
    }
    
    deinit {
        print("Deiniting AudioStreamReceiver")
		end()
    }
}

extension AudioStreamReader: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
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
			_playerNode.pause()
            return
        }
        
        guard inputStream.hasBytesAvailable else {
            print("[AudioStreamReader.pollStream] Stream has nothing to read")
            return
        }

        let inputData = Data(reading: inputStream)
        let audioBuffer = AVAudioPCMBuffer(data: inputData, audioFormat: AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!)!
        
        print(audioBuffer.frameLength)

		_playerNode.scheduleBuffer(audioBuffer, completionHandler: nil)
		_playerNode.play()
    }
}
