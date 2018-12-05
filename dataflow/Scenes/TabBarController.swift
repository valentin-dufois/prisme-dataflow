//
//  TabBarController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit

class TabBarController:UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(switchToReceiver), name: Notifications.switchToReceiver.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(switchToEmitter), name: Notifications.switchToEmitter.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(switchToReceiverConnectedStream), name: Notifications.connectedToEmitter.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(switchToReceiverNotConnectedStream), name: Notifications.disconnectedFromEmitter.name, object: nil)

		if(DataFlowDefaults.appType.string! == "receiver") {
			switchToReceiver()
		}
	}

	@objc func switchToEmitter() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)

		// Emitter tab
		let emitterViewController = storyboard.instantiateViewController(withIdentifier: "emitterViewController")

		// Stream tab
		let streamViewController = storyboard.instantiateViewController(withIdentifier: "streamEmitterViewController")

		self.viewControllers = [emitterViewController, streamViewController, self.viewControllers![1]]
		self.selectedIndex = 2
	}

	@objc func switchToReceiver() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)

		// Stream tab
		let streamViewController = storyboard.instantiateViewController(withIdentifier: "streamReceiverNotConnectedViewController")

		self.viewControllers = [streamViewController, self.viewControllers![2]]
		self.selectedIndex = 1
	}

	@objc func switchToReceiverConnectedStream() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)

		// Emitter/receiver tab
		let connectedStreamController = storyboard.instantiateViewController(withIdentifier: "streamReceiverConnectedViewController")

		self.viewControllers = [connectedStreamController, self.viewControllers![1]]
		self.selectedIndex = 0
	}

	@objc func switchToReceiverNotConnectedStream() {
		// Ensure this is executed on the main queue
		DispatchQueue.main.async {
			let storyboard = UIStoryboard(name: "Main", bundle: nil)

			// Emitter/receiver tab
			let disconnectedStreamController = storyboard.instantiateViewController(withIdentifier: "streamReceiverNotConnectedViewController")

			self.viewControllers = [disconnectedStreamController, self.viewControllers![1]]
			self.selectedIndex = 0
		}
	}
}
