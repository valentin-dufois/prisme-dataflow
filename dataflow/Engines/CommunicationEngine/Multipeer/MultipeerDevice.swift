//
//  MultipeerDevice.swift
//  dataflow
//
//  Created by Valentin Dufois on 05/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import MultipeerConnectivity

class MultipeerDevice: NSObject {

	// /////////////////
	// MARK: Properties

	/// The delegate
	var delegate: MultipeerDelegate?

	/// The unique ID for this device
	internal let _devicePeerID = MCPeerID(displayName: UIDevice.current.name)

	/// The name of the Multipeer service
	let peerServiceName: String

	/// The server session
	internal lazy var _session: MCSession! = initSession()

	/// Create the server with the given service name
	///
	/// - Parameter name: The name of the service
	init(serviceName name: String) {
		self.peerServiceName = name
	}

	/// Create the session for the peer connection server
	private func initSession() -> MCSession {
		let session =  MCSession(peer: _devicePeerID,
								 securityIdentity: nil,
								 encryptionPreference: .none)
		session.delegate = self
		return session
	}

	deinit {
		_session?.disconnect()
		_session = nil
	}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerDevice: MCNearbyServiceAdvertiserDelegate {
	/// Called when another peer sends an invitation
	///
	/// - Parameters:
	///   - advertiser: The current advertiser
	///   - peerID: The incoming peerID
	///   - context: The context that the incoming peer could have sent
	///   - invitationHandler: Handler to accept the invitation
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		if self.delegate?.mpDevice(self, shouldAcceptPeer: peerID, withContext: context) ?? false {
			invitationHandler(true, self._session)
		}
	}

	/// Called when the advertiser could not start
	///
	/// - Parameters:
	///   - advertiser: Current advertiser
	///   - error: Ongoing error
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		self.delegate?.mpDevice(self, didNotStart: error)
	}
}


// MARK: - MCSessionDelegate
extension MultipeerDevice: MCSessionDelegate {
	/// This is called any time a peer status gets updated.
	///
	/// - Parameters:
	///   - session: The current session
	///   - peerID: The peer who got updated
	///   - state: The new state of the given peer
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		self.delegate?.mpDevice(self, peerStateChanged: peerID, to: state)
	}

	/// Called when data are received from the connected peer
	///
	/// - Parameters:
	///   - session: The current session
	///   - data: The received data
	///   - peerID: The peer from which the data is coming
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		self.delegate?.mpDevice(self, receivedData: data, fromPeer: peerID)
	}

	/// Called when a stream are received from the connected peer
	///
	/// - Parameters:
	///   - session: The current session
	///   - stream: The incoming stream
	///   - streamName: The name of the incoming stream
	///   - peerID: The peer from which the stream is coming
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		self.delegate?.mpDevice(self, receivedStream: stream, withName: streamName, fromPeer: peerID)
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
