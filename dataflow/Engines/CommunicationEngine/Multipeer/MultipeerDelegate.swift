//
//  MultipeerDelegate.swift
//  dataflow
//
//  Created by Valentin Dufois on 05/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import MultipeerConnectivity

/// The MultipeerDelegate is used by the `MultipeerServer` and `MultipeerClient` to
/// Provide event handling
protocol MultipeerDelegate {
	/// Called when the server receives an invitation.
	///
	/// - Parameters:
	///   - device: The current server
	///   - peer: The requesting peer
	///   - context: The context provided by the peer
	/// - Returns: True to accept the invitation, false to decline
	func mpDevice(_ device: MultipeerDevice, shouldAcceptPeer peer: MCPeerID, withContext context: Data?) -> Bool

	/// Called when the device could not start properly
	///
	/// - Parameters:
	///   - device: The current device
	///   - error: The error
	func mpDevice(_ device: MultipeerDevice, didNotStart error: Error)

	/// Called when the status of a peer changes
	///
	/// - Parameters:
	///   - device: The current device
	///   - peer: The peer
	///   - state: The new state of the peer
	func mpDevice(_ device: MultipeerDevice, peerStateChanged peer: MCPeerID, to state: MCSessionState)

	/// Called data are received
	///
	/// - Parameters:
	///   - device: The current device
	///   - data: The received data
	///   - peer: The peer sending the data
	func mpDevice(_ device: MultipeerDevice, receivedData data: Data, fromPeer peer: MCPeerID)

	/// Called when a stream is received
	///
	/// - Parameters:
	///   - device: The current device
	///   - stream: The received stream
	///   - name: The name of the stream
	///   - peer: The peer sending the stream
	func mpDevice(_ device: MultipeerDevice, receivedStream stream: InputStream, withName streamName: String, fromPeer peer: MCPeerID)
}

// MARK: - Optional methods
extension MultipeerDelegate {
	func mpDevice(_ device: MultipeerDevice, shouldAcceptPeer peer: MCPeerID, withContext context: Data?) -> Bool {
		return false
	}
	func mpDevice(_ device: MultipeerDevice, didNotStart error: Error) { }
	func mpDevice(_ device: MultipeerDevice, peerStateChanged peer: MCPeerID, to state: MCSessionState) { }
	func mpDevice(_ device: MultipeerDevice, receivedData data: Data, fromPeer peer: MCPeerID) { }
	func mpDevice(_ device: MultipeerDevice, receivedStream stream: InputStream, withName streamName: String, fromPeer peer: MCPeerID) { }
}
