//
//  ReceiverNotConnectedStreamController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity
import QuartzCore

class ReceiverNotConnectedStreamController: UIViewController {
	private var _advertiserAssistant:MCAdvertiserAssistant!
	private var _browserController:MCBrowserViewController!

	@IBAction func openEmitterSelectionInterface() {
		let _browserController = MCBrowserViewController(serviceType: App.communicator._peerServiceID, session: App.communicator.session)
		_browserController.delegate = self
		_browserController.maximumNumberOfPeers = 1
		present(_browserController, animated: true)
	}
}

extension ReceiverNotConnectedStreamController: MCBrowserViewControllerDelegate {
	func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
		dismiss(animated: true)
		NotificationCenter.default.post(name: Notifications.connectedToEmitter.name, object: nil)
	}

	func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
		App.communicator.session.disconnect()
		dismiss(animated: true)
	}
}
