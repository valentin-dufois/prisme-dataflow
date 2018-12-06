//
//  AVAudioPCMBuffer.swift
//  dataflow
//
//  Created by Valentin Dufois on 06/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import AVFoundation

extension AVAudioPCMBuffer {
	func toData() -> Data {
		let audioBuffer = self.audioBufferList.pointee.mBuffers
		return Data(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
	}

	convenience init?(data: Data, audioFormat format: AVAudioFormat) {
		let streamDescriptor = format.streamDescription.pointee
		let frameCapacity = UInt32(data.count) / streamDescriptor.mBytesPerFrame

		// Create the buffer
		self.init(pcmFormat: format, frameCapacity: frameCapacity)

		self.frameLength = self.frameCapacity
		let audioBuffer = self.audioBufferList.pointee.mBuffers

		data.withUnsafeBytes { bytes in
			audioBuffer.mData?.copyMemory(from: bytes, byteCount: Int(audioBuffer.mDataByteSize))
		}
	}
}
