//
//  MultipeerSession.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 04/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension Communicator: MCSessionDelegate {
	/// This is called any time a peer status gets updated.
	/// This sends notifications in case of a connected or notConnected event
	///
	/// - Parameters:
	///   - session: The current session
	///   - peerID: The peer who got updated
	///   - state: The new state of the given peer
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		switch state {
		case .connected:
				NotificationCenter.default.post(name: Notifications.peerConnected.name, object: nil)
		case .connecting: break
		case .notConnected:
			NotificationCenter.default.post(name: Notifications.peerDisconnected.name, object: nil)
		}
	}

	/// Called when data are received from the connected peer
	///
	/// - Parameters:
	///   - session: The current session
	///   - data: The received data
	///   - peerID: The peer from which the data is coming
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		print("Received \(data.count) elements of data from \(peerID.displayName)")
	}

	/// Called when a stream are received from the connected peer
	///
	/// - Parameters:
	///   - session: The current session
	///   - stream: The incoming stream
	///   - streamName: The name of the incoming stream
	///   - peerID: The peer from which the stream is coming
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		print("Received a stream from \(peerID.displayName)")
	}


	// ///////////////
	// MARK: - UNUSED

	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		print("Starting receiving resource \(resourceName) from \(peerID.displayName)")
	}

	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		print("Finished receiving resource \(resourceName) from \(peerID.displayName)")
	}
}
