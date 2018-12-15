//
//  SettingsController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 02/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit

/// Unused
class SettingsController:UINavigationController {
}

/// The TableController for the settings pane
class SettingsTableController:UITableViewController {
	@IBOutlet var serverURLField: UITextField!
	@IBOutlet var serverPortField: UITextField!
	@IBOutlet var appTypeControl: UISegmentedControl!
    @IBOutlet weak var audioGainLabel: UITextField!

	/// Called when the view is loaded
	override func viewDidLoad() {
		serverURLField.text = DataFlowDefaults.serverURL.url!.absoluteString
		serverPortField.text = "\(DataFlowDefaults.serverPort.integer!)"
		if(DataFlowDefaults.appType.string! == "receiver") {
			appTypeControl.selectedSegmentIndex = 1
		}
        audioGainLabel.text = "\(DataFlowDefaults.audioGain.double!)"
	}

	/// Called every time the view is shown
	override func viewDidDisappear(_ animated: Bool) {
		DataFlowDefaults.serverURL.set(value: URL(string: serverURLField.text!)!)
		DataFlowDefaults.serverPort.set(value: Int(serverPortField.text!)!)
        DataFlowDefaults.audioGain.set(value: Double(audioGainLabel.text!)!)

		NotificationCenter.default.post(name: Notifications.settingsUpdated.name, object: nil)
	}

	/// Called when the user changes the appType useing the splitButton.
	/// Trigger an update of the tabs
	///
	/// - Parameter sender: The sender
	@IBAction func onAppTypeChanged(_ sender: Any) {
		// Switch from emitter to receiver
		if(DataFlowDefaults.appType.string == "emitter") {
			DataFlowDefaults.appType.set(value: "receiver")
			NotificationCenter.default.post(name: Notifications.switchToReceiver.name, object: nil)
			return
		}

		// Switch from receiver to emitter
		DataFlowDefaults.appType.set(value: "emitter")
		NotificationCenter.default.post(name: Notifications.switchToEmitter.name, object: nil)
	}
}
