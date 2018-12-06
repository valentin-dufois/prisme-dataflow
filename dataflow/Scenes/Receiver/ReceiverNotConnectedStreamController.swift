//
//  ReceiverNotConnectedStreamController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import UIKit

class ReceiverNotConnectedStreamController: UIViewController {
	@IBAction func openEmitterSelectionInterface() {
		(self.parent! as! ReceiverController).connectToServer()
	}
}
