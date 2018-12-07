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
import AVFoundation

class ReceiverConnectedStreamController: UIViewController {
	@IBOutlet weak var emitterLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		emitterLabel.text = (self.parent! as! ReceiverController)._multipeerClient?.serverPeer?.displayName
	}

	@IBAction func disconnect(_ sender: Any) {
		(self.parent! as! ReceiverController).disconnectFromServer()
	}
    
    @IBAction func debug( _sender: Any) {
        NotificationCenter.default.post(name: Notifications.debug.name, object: nil)
    }
}
