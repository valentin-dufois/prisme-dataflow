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

		DispatchQueue.main.async {
            self.setViewControllers([emitterViewController, streamViewController, self.viewControllers![1]], animated: true)
		}
	}

	@objc func switchToReceiver() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)

		// Stream tab
		let receiverViewController = storyboard.instantiateViewController(withIdentifier: "ReceiverViewController")

		DispatchQueue.main.async {
            self.setViewControllers([receiverViewController, self.viewControllers![2]], animated: true)
		}
	}
}
