//
//  ReceiverConnectedStreamController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit

class ReceiverConnectedStreamController: UIViewController {
	@IBOutlet weak var emitterLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		emitterLabel.text = (self.parent! as! ReceiverController)._multipeerClient?.serverPeer?.displayName
	}

	@IBAction func disconnect(_ sender: Any) {
		(self.parent! as! ReceiverController).disconnectFromServer()
	}
	@IBAction func restartAudio(_ sender: Any) {
		App.audioEngine.stop()
		App.audioEngine.start()
	}
}
