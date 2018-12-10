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
import Repeat

/// An AudioStreamReader takes an InputStream receiving AVAudioPCMBuffer buffers encoded
/// into data, decodes them, and plays it
class AudioStreamReader: NSObject {
    
    // //////////////////////////////
    // MARK: Input stream properties

    internal var _inputStream: InputStream?
    internal var _timerInterval: Repeater.Interval = .seconds(0.5)
	internal var _timer: Repeater?

	internal var _audioFormat: AVAudioFormat!
    internal var _tempTimer: Repeater?
    
    internal var _allowedBufferSize:[UInt32] = [21504, 21638, 21639, 22016, 22528, 22579]

	private var _muted: Bool = false
	var muted: Bool { return _muted }

	/// Init the AudioStreamReader and directly start pmlaying the given stream
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
		// Store the stream
        _inputStream = stream

        if _timer == nil {
            _timer = Repeater(interval: self._timerInterval) { [weak self] timer in
                guard let `self` = self else { return }
                self.pollStream()
            }
        }
        
		DispatchQueue.main.async {
            self._tempTimer = Repeater.once(after: .seconds(0.5)) { timer in
                self._timer?.start()
            }
        
            self._inputStream!.schedule(in: .current, forMode: .common)
            self._inputStream!.open()
		}
    }

	func mute() {
		_muted = true
	}

	func unMute() {
		_muted = false
	}
    
	/// End playing the stream: Close the incoming stream and the audioEngine.
	///
	/// A new AudioStreamReader must be created to play another stream
    func end() {
        _inputStream?.close()
		_timer?.pause()
    }

	/// Make sure we properly stops all our elements
    deinit {
		end()
        
        _timer?.removeAllObservers()
    }
}


/// MARK: - Polling the stream
extension AudioStreamReader {
    func pollStream() {
		// Make sure we have a stream in the first place
        guard let inputStream = _inputStream else {
            print("[AudioStreamReader.pollStream] There is no stream to poll")
            return
        }

		// Does the stream holds informations ?
        guard inputStream.hasBytesAvailable else {
//            print("[AudioStreamReader.pollStream] Stream has nothing to read")
            return
        }

		// Extract and convert the stream informations to an audio buffer
        let inputData = Data(reading: inputStream)
        let audioBuffer = AVAudioPCMBuffer(data: inputData, audioFormat: App.audioEngine.audioFormat)!

		// Do not play the buffer we are muted
		if self.muted {
			return
		}

        // If the buffer has an unknown size, skip it
        guard _allowedBufferSize.contains(audioBuffer.frameLength) else {
            print("Skipped buffer of size \(audioBuffer.frameLength)")
            return;
        }
        
		// Play the buffer
        App.audioAnalysisQueue.async {
            App.audioEngine.play(buffer: audioBuffer)
        }
    }
}
