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

	private var _storyboard: UIStoryboard!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Store a reference to the storyboard
		_storyboard = UIStoryboard(name: "Main", bundle: nil)

		if(DataFlowDefaults.appType.string! == "emitter") {
			self.setViewControllers(emitterControllersSet, animated: false)
			App.emitterStream = (self.viewControllers![1] as! EmitterStreamController)
		} else {
			self.setViewControllers(receiverControllersSet, animated: false)
		}


		/// Add Observers
		NotificationCenter.default.addObserver(self, selector: #selector(switchToReceiver), name: Notifications.switchToReceiver.name, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(switchToEmitter), name: Notifications.switchToEmitter.name, object: nil)
	}

	@objc func switchToEmitter() {
		DispatchQueue.main.async {
			self.setViewControllers([self.emitterViewController, self.streamViewController, self.viewControllers![1]], animated: false)
			App.emitterStream = (self.viewControllers![1] as! EmitterStreamController)
		}
	}

	@objc func switchToReceiver() {
		DispatchQueue.main.async {
            self.setViewControllers([self.receiverViewController, self.viewControllers![2]], animated: false)
		}
	}
}

// MARK: - ViewControllers getters
extension TabBarController {
	private var emitterViewController: UIViewController {
		return _storyboard.instantiateViewController(withIdentifier: "emitterViewController")
	}

	private var streamViewController: UIViewController {
		return _storyboard.instantiateViewController(withIdentifier: "streamViewController")
	}

	private var receiverViewController: UIViewController {
		return _storyboard.instantiateViewController(withIdentifier: "receiverViewController")
	}

	private var settingsViewController: UIViewController {
		return _storyboard.instantiateViewController(withIdentifier: "settingsViewController")
	}

	private var emitterControllersSet: [UIViewController] {
		return [emitterViewController, streamViewController, settingsViewController]
	}

	private var receiverControllersSet: [UIViewController] {
		return [receiverViewController, settingsViewController]
	}
}
