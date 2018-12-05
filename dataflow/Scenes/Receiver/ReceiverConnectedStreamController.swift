//
//  ReceiverConnectedStreamController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity
import QuartzCore

class ReceiverConnectedStreamController: UIViewController {
	@IBOutlet weak var emitterLabel: UILabel!

	override func viewDidLoad() {
		NotificationCenter.default.addObserver(self, selector: #selector(disconnectFromEmitter), name: Notifications.peerDisconnected.name, object: nil)
	}

	override func viewDidAppear(_ animated: Bool) {
		emitterLabel.text = App.communicator.session.connectedPeers.first!.displayName
	}

	@IBAction func disconnectFromEmitter() {
		App.communicator.session.disconnect()
		NotificationCenter.default.post(name: Notifications.disconnectedFromEmitter.name, object: nil)
	}
}
