//
//  ReceiverNotConnectedStreamController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import UIKit

/// The view shown on the receiver ends when we are not connected to a server
class ReceiverNotConnectedStreamController: UIViewController {
	/// Called when the user wants to connect to the server
	@IBAction func openEmitterSelectionInterface() {
		(self.parent! as! ReceiverController).connectToServer()
	}
}
