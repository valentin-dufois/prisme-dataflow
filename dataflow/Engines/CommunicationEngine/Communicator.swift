//
//  Communicator.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 28/11/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import SwiftSocket
import MultipeerConnectivity

class Communicator: NSObject {
	// ////////////////////
	// MARK: Singleton

	/// Hold the singleton instance
	private static var _instance:Communicator?

	/// get an instance of the engine. Instanciate it if needed.
	static var instance:Communicator {
		get {
			guard _instance == nil else { return _instance! }

			_instance = Communicator()
			return _instance!
		}
	}


	// ////////////////////
	// MARK: Socket connection properties

	internal var _socketClient:TCPClient!

	internal var _isSocketConnected:Bool = false


	// //////////////////////////////////////
	// MARK: Multipeer connection properties

	internal var _peerServiceID = "prisme-dataflow"

	internal var _devicePeerID = MCPeerID(displayName: UIDevice.current.name)

	internal var _peerServiceAdvertiser:MCNearbyServiceAdvertiser?

	internal var _peerServiceBrowser:MCNearbyServiceBrowser?

	internal lazy var _session: MCSession = {
		let session = MCSession(peer: _devicePeerID, securityIdentity: nil, encryptionPreference: .required)
		session.delegate = self
		return session
	}()

	public var session: MCSession {
		return _session
	}

	internal var _peersOutputStreams:[String: OutputStream] = [String: OutputStream]()


	// ////////////
	// MARK: INIT

	/// Mark init as private to prevent oustide init
	private override init() {
		super.init()
		// Add observer for UserDefaultUpdate to reconnect with the new settings
		NotificationCenter.default.addObserver(self, selector: #selector(onSettingsUpdated), name: Notifications.settingsUpdated.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(switchToReceiver), name: Notifications.switchToReceiver.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(switchToEmiter), name: Notifications.switchToEmitter.name, object: nil)
	}

	// /////////////
	// MARK: Events

	@objc internal func onSettingsUpdated() {
		if(_isSocketConnected) {
			reconnectToSocket()
		}
	}

	@objc internal func switchToReceiver() {
		endEmitter()
	}

	@objc internal func switchToEmiter() {
		startEmitter()
	}

}


// MARK: - Start/Stop methods
extension Communicator {
	func start() {
		if(DataFlowDefaults.appType.string! == "emitter") {
			startEmitter()
		}

	}

	func startEmitter() {
		// Connect to the socket
		connectToSocket()

		// Initialize the peer service
		openPeerServer()
	}

	func endEmitter() {
		deconnectFromSocket()
		closePeerServer()
	}
}
