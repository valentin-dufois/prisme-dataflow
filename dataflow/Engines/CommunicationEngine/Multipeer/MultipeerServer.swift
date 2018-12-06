//
//  MultipeerServer.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import MultipeerConnectivity

class MultipeerServer: MultipeerDevice {

	// /////////////////
	// MARK: Properties

	/// The advertiser used make ourself discoverable
	private var _peerServiceAdvertiser: MCNearbyServiceAdvertiser!

	deinit {
		close()
	}
}


// MARK: - Server start and shutdown
extension MultipeerServer {
	/// Open the server, making it discoverable by clients
	func open() {
		_peerServiceAdvertiser = MCNearbyServiceAdvertiser(peer: _devicePeerID,
														   discoveryInfo: nil,
														   serviceType: self.peerServiceName)

		_peerServiceAdvertiser!.delegate = self
		_peerServiceAdvertiser!.startAdvertisingPeer()
	}

	// Close the server, closing all available connection
	func close() {
		_peerServiceAdvertiser?.stopAdvertisingPeer()
		_peerServiceAdvertiser = nil

		_session?.disconnect()
	}
}


// MARK: - Convenient session accesses
extension MultipeerServer {
	var connectedPeers: [MCPeerID] {
		return _session.connectedPeers
	}

	func createStream(forPeer peer: MCPeerID) throws -> OutputStream {
		return try _session.startStream(withName: peer.displayName, toPeer: peer)
	}
}
