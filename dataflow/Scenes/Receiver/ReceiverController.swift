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

	/// The children view currently displayed
	internal var _childrenView: UIViewController?

	// ///////////////////////
	// MARK: Multipeer Client

	/// The client used to talk with our emitter
	internal var _multipeerClient: MultipeerClient?

	/// The stream reader to play incoming streams
	internal var _audioStreamReader: AudioStreamReader?

	// ////////////////////
	// MARK: Audio emition

	/// The listening engine to send our audio to the server
	internal var _listeningEngine: AudioListeningEngine?

	/// The output stream to the server
	internal var _outputStream: OutputStream?



	/// When the view is loaded, display the `not connected`view
	override func viewDidLoad() {
		super.viewDidLoad()

		switchToDisconnected()
	}

	/// Display the connected view
	func switchToConnected() {
		// Update the current view
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let connectedViewController = storyboard.instantiateViewController(withIdentifier: "receiverConnectedView")

		displayChild(controller: connectedViewController)

		startAudioEmition()
	}

	/// Display the not connected view
	func switchToDisconnected() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let notConnectedViewController = storyboard.instantiateViewController(withIdentifier: "receiverNotConnectedView")

		displayChild(controller: notConnectedViewController)

		// Erase the listening engine and the output stream
		_listeningEngine = nil
		_outputStream?.close()
		_outputStream = nil
	}


	/// Display the given view in the view container. Properly remove the currently
	/// present subview if needed
	///
	/// - Parameter controller: The controller to place as a subview
	private func displayChild(controller: UIViewController) {
		// UI modifications must take place in the main queue
		DispatchQueue.main.async {
			// Remove the current ssubview if needed
			if let childrenView = self._childrenView {
				childrenView.willMove(toParent: nil)
				childrenView.view.removeFromSuperview()
				childrenView.removeFromParent()
			}

			// Place the new subview
			self.addChild(controller)
			controller.view.frame = self.insetView.frame
			self.view.addSubview(controller.view)
			controller.didMove(toParent: self)

			self._childrenView = controller
		}
	}
}


// MARK: - Connectivity related methods
extension ReceiverController {
	/// Try to connect to the server
	func connectToServer() {
		_multipeerClient = MultipeerClient(serviceName: DataFlowDefaults.peerServiceName.string!)
		_multipeerClient?.delegate = self

		_multipeerClient?.open(onView: self, maximumNumberOfPeers: 1)
	}

	/// Disconnect from the server
	func disconnectFromServer() {
		_multipeerClient?.close()
		_multipeerClient = nil
        
        _audioStreamReader?.end()

		endAudioEmition()

		_outputStream?.close()

		switchToConnected()
	}
}

extension ReceiverController: MultipeerDelegate {
	/// Stop the application if we couldn't starg the client
	func mpDevice(_ device: MultipeerDevice, didNotStart error: Error) {
		fatalError("[ReceiverController] Could not start MultipeerClient : \(error.localizedDescription)")
	}

	/// Watch for server state changes to connect or disconnect ourselves if needed
	func mpDevice(_ device: MultipeerDevice, peerStateChanged peer: MCPeerID, to state: MCSessionState) {
		switch state {
		case .connected:
			connectToServer()
		case .notConnected:
			disconnectFromServer()
		default: break
		}
	}

	// Start reading any received stream
	func mpDevice(_ device: MultipeerDevice, receivedStream stream: InputStream, withName streamName: String, fromPeer peer: MCPeerID) {
        // End the current stream if there is one
        _audioStreamReader?.end()

		// Create and start the audio stream reader with the received stream
		_audioStreamReader = AudioStreamReader(stream: stream)

		// Create our own stream to the server
		_outputStream = try! device.makeStream(forPeer: peer)
		_outputStream!.schedule(in: .current, forMode: .common)
		_outputStream!.open()
	}
}



// MARK: - Audio Emition
extension ReceiverController: AudioListeningEngineDelegate {

	private func startAudioEmition() {
		_listeningEngine = AudioListeningEngine()
		_listeningEngine?.delegate = self
		_listeningEngine?.start()
	}

	func audioEngine(_ listeningAudioEngine: AudioListeningEngine, hasBuffer buffer: AVAudioPCMBuffer) {
		guard let outputStream = _outputStream else { return }

		let audioData = buffer.toData()

		_ = audioData.withUnsafeBytes { dataPointer in
			outputStream.write(dataPointer, maxLength: audioData.count)
		}
	}

	private func endAudioEmition() {
		_listeningEngine?.stop()
		_listeningEngine = nil
	}
}
