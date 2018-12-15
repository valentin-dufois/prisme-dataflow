//
//  ReceiverConnectedStreamController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit

/// The view shown on the receiver ends when we are connected to a server
class ReceiverConnectedStreamController: UIViewController {
	/// The name of the emitter server
	@IBOutlet weak var emitterLabel: UILabel!

	/// Called when the view is loaded
	override func viewDidLoad() {
		super.viewDidLoad()

		emitterLabel.text = (self.parent! as! ReceiverController)._multipeerClient?.serverPeer?.displayName
	}

	/// Calles when the user wants to disconnect from the server
	///
	/// - Parameter sender: The sender item
	@IBAction func disconnect(_ sender: Any) {
		(self.parent! as! ReceiverController).disconnectFromServer()
	}

	/// Called when the user wants to restart the audio
	///
	/// - Parameter sender: The sender item
	@IBAction func restartAudio(_ sender: Any) {
		App.audioEngine.stop()
		App.audioEngine.start()
	}
}
