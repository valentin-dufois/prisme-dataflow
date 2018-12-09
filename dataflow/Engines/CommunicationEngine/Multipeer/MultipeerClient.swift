//
//  MultipeerClient.swift
//  dataflow
//
//  Created by Valentin Dufois on 05/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MultipeerClient: MultipeerDevice {

	// /////////////////
	// MARK: Properties

	private var _parentViewController: UIViewController?

}


// MARK: - Client start and shutdown
extension MultipeerClient {

	/// Create and present the BrowserViewController to select a server to connect to
	///
	/// - Parameters:
	///   - viewController: The viewController to present the browser on top of
	///   - maximumNumberOfPeers: The maximum number of peers the browsr should be able to connect to (max 8)
	func open(onView viewController:UIViewController, maximumNumberOfPeers: Int) {
		_parentViewController = viewController

		let _browserController = MCBrowserViewController(serviceType: self.peerServiceName, session: _session)
		_browserController.delegate = self
		_browserController.maximumNumberOfPeers = 1

		_parentViewController?.present(_browserController, animated: true)
	}

	/// Properly close the session with the server (if any)
	func close() {
		_session.disconnect()
	}
}

// MARK: - Delegate methods for the BrowserViewController
extension MultipeerClient: MCBrowserViewControllerDelegate {
	func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
		_parentViewController?.dismiss(animated: true)
	}

	func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
		_parentViewController?.dismiss(animated: true)
	}
}


// MARK: - Convenient session methods
extension MultipeerClient {
	var serverPeer: MCPeerID? {
		return _session.connectedPeers.last
	}
}
