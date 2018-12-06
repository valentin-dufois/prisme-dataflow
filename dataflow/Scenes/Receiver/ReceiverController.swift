//
//  ReceiverController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity
import AVFoundation

class ReceiverController: UIViewController {
	// //////////////
	// MARK: Outlets
	@IBOutlet var insetView: UIView!

	// /////////////////
	// MARK: Properties

	internal var _childrenView: UIViewController?

	internal var _multipeerClient: MultipeerClient?

	internal var _inputStream: InputStream?

	override func viewDidLoad() {
		super.viewDidLoad()

		displayNotConnectedView()
	}

	func displayNotConnectedView() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let notConnectedViewController = storyboard.instantiateViewController(withIdentifier: "receiverNotConnectedView")

		displayChild(controller: notConnectedViewController)
	}

	func displayConnectedView() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let connectedViewController = storyboard.instantiateViewController(withIdentifier: "receiverConnectedView")

		displayChild(controller: connectedViewController)
	}


	private func displayChild(controller: UIViewController) {
		DispatchQueue.main.async {
			if let childrenView = self._childrenView {
				childrenView.willMove(toParent: nil)
				childrenView.view.removeFromSuperview()
				childrenView.removeFromParent()
			}

			self.addChild(controller)
			controller.view.frame = self.insetView.frame
			self.view.addSubview(controller.view)
			controller.didMove(toParent: self)

			self._childrenView = controller
		}
	}
}


extension ReceiverController {
	func connectToServer() {
		_multipeerClient = MultipeerClient(serviceName: DataFlowDefaults.peerServiceName.string!)
		_multipeerClient?.delegate = self

		_multipeerClient?.open(onView: self, maximumNumberOfPeers: 1)
	}

	func disconnectFromServer() {
		_multipeerClient?.close()
		_multipeerClient = nil

		closeStream()

		displayNotConnectedView()
	}

	func closeStream() {
		_inputStream?.close()
		_inputStream = nil
	}
}

extension ReceiverController: MultipeerDelegate {
	func mpDevice(_ device: MultipeerDevice, didNotStart error: Error) {
		fatalError("[ReceiverController] Could not start MultipeerClient : \(error.localizedDescription)")
	}

	func mpDevice(_ device: MultipeerDevice, peerStateChanged peer: MCPeerID, to state: MCSessionState) {
		switch state {
		case .connected:
			displayConnectedView()
		case .notConnected:
			disconnectFromServer()
		default: break
		}
	}

	func mpDevice(_ device: MultipeerDevice, receivedStream stream: InputStream, withName streamName: String, fromPeer peer: MCPeerID) {
		_inputStream = stream
		_inputStream?.delegate = self
		_inputStream?.schedule(in: .current, forMode: .common)
	}
}

extension ReceiverController: StreamDelegate {
	func stream(_ stream: Stream, handle event: Stream.Event) {
		switch event {
		case .hasBytesAvailable:
			pollStream()
		case .endEncountered:
			closeStream()
		default: break
		}
	}

	func pollStream() {
		guard let inputStream = _inputStream else {
			print("[ReceiverController.pollStream] There is no stream to poll")
			return
		}

		let inputData = Data(reading: inputStream)
		let audioBuffer = AVAudioPCMBuffer(data: inputData, audioFormat: AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!)!

		print(audioBuffer.frameLength)
	}
}
