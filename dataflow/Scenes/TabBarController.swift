//
//  TabBarController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit

/// The TabBarController handle the tab bar of the app, as well as the app type changes
class TabBarController:UITabBarController {

	/// The storyboard holding our views
	private var _storyboard: UIStoryboard!

	/// Called when the view is loaded
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

	/// Changes the tab bar to the emitter type
	@objc func switchToEmitter() {
		DispatchQueue.main.async {
			self.setViewControllers([self.emitterViewController, self.streamViewController, self.viewControllers![1]], animated: false)
			App.emitterStream = (self.viewControllers![1] as! EmitterStreamController)
		}
	}

	/// Changes the tab bar to the receiver type
	@objc func switchToReceiver() {
		DispatchQueue.main.async {
            self.setViewControllers([self.receiverViewController, self.viewControllers![2]], animated: false)
		}
	}
}

// MARK: - ViewControllers getters
extension TabBarController {
	/// Gets the emitterViewController from the storyboard
	private var emitterViewController: UIViewController {
		return _storyboard.instantiateViewController(withIdentifier: "emitterViewController")
	}

	/// Gets the streamViewController from the storyboard
	private var streamViewController: UIViewController {
		return _storyboard.instantiateViewController(withIdentifier: "streamViewController")
	}

	/// Gets the receiverViewController from the storyboard
	private var receiverViewController: UIViewController {
		return _storyboard.instantiateViewController(withIdentifier: "receiverViewController")
	}

	/// Gets the settingsViewController from the storyboard
	private var settingsViewController: UIViewController {
		return _storyboard.instantiateViewController(withIdentifier: "settingsViewController")
	}

	/// Gets the emitterControllersSet from the storyboard
	private var emitterControllersSet: [UIViewController] {
		return [emitterViewController, streamViewController, settingsViewController]
	}

	/// Gets the receiverControllersSet from the storyboard
	private var receiverControllersSet: [UIViewController] {
		return [receiverViewController, settingsViewController]
	}
}
