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

/// An AudioStreamReader takes an InputStream receiving AVAudioPCMBuffer buffers encoded
/// into data, decodes them, and plays it
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

	/// Init the audio engine to allow for playing audio comming from the stream
	override init() {
		_audioInput = _audioEngine.inputNode
		_audioEngine.attach(_playerNode)
		_audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)

		_audioEngine.connect(_playerNode, to: _audioEngine.mainMixerNode, format: _audioFormat)

		_audioEngine.prepare()
	}

	/// Init the AudioStreamReader anddirectly start pmlaying the given stream
	///
	/// - Parameter stream: The stream holding audio informations
	convenience init(stream: InputStream) {
		self.init()

		read(stream: stream)
	}

    /// Store and schedule the incoming stream
    ///
    /// - Parameter stream: The stream to play
    func read(stream: InputStream) {
		// Store and schedule the stream
        _inputStream = stream
		self._inputStream!.schedule(in: .current, forMode: .common)

		// Start the audio Engine
		try! _audioEngine.start()

		DispatchQueue.main.async {
			dispatchPrecondition(condition: .onQueue(.main))
			self._timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.pollStream), userInfo: nil, repeats: true)

			self._inputStream!.open()
		}
    }
    
	/// End playing the stream: Close the incoming stream and the audioEngine.
	///
	/// A new AudioStreamReader must be created to play another stream
    func end() {
        _inputStream?.close()
		_timer?.invalidate()

		_audioEngine.stop()
		_playerNode.stop()
    }

	/// Make sure we properly stops all our elements
    deinit {
		end()
    }
}

/// MARK: - Polling the stream
extension AudioStreamReader {
    @objc func pollStream() {
		// Make sure we have a stream in the first place
        guard let inputStream = _inputStream else {
            print("[AudioStreamReader.pollStream] There is no stream to poll")
			_playerNode.pause()
            return
        }

		// Does the stream holds informations ?
        guard inputStream.hasBytesAvailable else {
            print("[AudioStreamReader.pollStream] Stream has nothing to read")
			_playerNode.pause()
            return
        }

		// Extract and convert the stream informations to an audio buffer
        let inputData = Data(reading: inputStream)
        let audioBuffer = AVAudioPCMBuffer(data: inputData, audioFormat: AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!)!

		// Play the buffer
		_playerNode.scheduleBuffer(audioBuffer, completionHandler: nil)
		_playerNode.play()
    }
}
