//
//  MultipeerClient.swift
//  dataflow
//
//  Created by Valentin Dufois on 05/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import UIKit
import MultipeerConnectivity

/// Used to create a client for a multipeer connectivity server
class MultipeerClient: MultipeerDevice {

	// /////////////////
	// MARK: Properties

	/// The parent view controller to attache the service browser to
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
	/// Called whe the browser view controller ends with a connection (`Done` sbutton)
	///
	/// - Parameter browserViewController: The browser view controller
	func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
		_parentViewController?.dismiss(animated: true)
	}

	/// Called whe the browser view controller was cancelled
	///
	/// - Parameter browserViewController: The browser view controller
	func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
		_parentViewController?.dismiss(animated: true)
	}
}


// MARK: - Convenient session methods
extension MultipeerClient {
	/// Gives the server peer ID if we are connected to a server
	var serverPeer: MCPeerID? {
		return _session.connectedPeers.last
	}
}
