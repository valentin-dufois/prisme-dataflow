//
//  MultipeerServer.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension Communicator {
	internal func openPeerServer() {
		_peerServiceAdvertiser = MCNearbyServiceAdvertiser(peer: _devicePeerID, discoveryInfo: nil, serviceType: _peerServiceID)

		_peerServiceAdvertiser!.delegate = self
		_peerServiceAdvertiser!.startAdvertisingPeer()
	}



	internal func closePeerServer() {
		_peerServiceAdvertiser?.stopAdvertisingPeer()
		_peerServiceAdvertiser = nil
	}
}

extension Communicator: MCNearbyServiceAdvertiserDelegate {
	/// Accept any incoming invitation
	///
	/// - Parameters:
	///   - advertiser: The current advertiser
	///   - peerID: The incoming peerID
	///   - context: The context that the incoming peer could have sent
	///   - invitationHandler: Handler to accept the invitation
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		// Accept invitation
		invitationHandler(true, self._session)

		// Create and store an output stream for this peer
//		let outputStream = try! _session.startStream(withName: "audioStream", toPeer: peerID)
//		_peersOutputStreams[peerID.displayName] = outputStream
	}

	/// Let's crash if we couldn't open the service
	///
	/// - Parameters:
	///   - advertiser: Current advertiser
	///   - error: Ongoing error
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		fatalError("Did not start advertising from service : \(error.localizedDescription)")
	}
}
