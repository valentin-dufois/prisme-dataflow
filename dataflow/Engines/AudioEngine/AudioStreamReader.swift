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

    /// The input stream from which informations will be read
    internal var _inputStream: InputStream?

	/// Interval in time between each read on the input buffer
    internal var _timerInterval: Repeater.Interval = .seconds(0.5)

	/// Timer triggering reads on the input buffer
	internal var _timer: Repeater?

	/// The temp timer used to delay the stream start
	internal var _tempTimer: Repeater?

	/// Buffer sizes allowed when playing from the input stream
	internal var _allowedBufferSize:[UInt32] = [21504,
												21638,
												21639,
												// 21757, // Seems good // Meh
												22016,
												22186,
//												22305, bad
												22528,
												22579,
												22580,
//												23040,
//												23520,
												]

	/// Tells if the engine is currently muted
	private var _muted: Bool = false

	/// Tells if the engine is currently muted
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

	/// Mute the engine
	func mute() {
		_muted = true
	}

	/// Unmute the engine
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
    /// Called by the timer interval to read on the input stream and play the received buffer
    func pollStream() {
		// Make sure we have a stream in the first place
        guard let inputStream = _inputStream else {
            print("[AudioStreamReader.pollStream] There is no stream to poll")
            return
        }

		// Does the stream holds informations ?
        guard inputStream.hasBytesAvailable else {
			// print("[AudioStreamReader.pollStream] Stream has nothing to read")
            return
        }

		// Extract and convert the stream informations to an audio buffer
        let inputData = Data(reading: inputStream)
        let audioBuffer = AVAudioPCMBuffer(data: inputData, audioFormat: App.audioEngine.audioFormat)!

		// Do not play the buffer we are muted
		if self.muted {
			return
		}

		guard _allowedBufferSize.contains(audioBuffer.frameLength) else {
		    print("Skipped buffer of size \(audioBuffer.frameLength)")
            return;
        }
        
		// Play the buffer on the audioAnalysis queue for better performances
        App.audioAnalysisQueue.async {
            App.audioEngine.play(buffer: audioBuffer)
        }
    }
}
