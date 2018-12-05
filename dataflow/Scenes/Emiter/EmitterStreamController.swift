//
//  EmitterStreamController.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class EmitterStreamController: UITableViewController {

	override func viewDidLoad() {
		// Add observer
		NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notifications.peerConnected.name, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notifications.peerDisconnected.name, object: nil)
	}

	@objc func refresh() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return App.communicator.session.connectedPeers.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "receiverCell")!
		cell.textLabel?.text = App.communicator.session.connectedPeers[indexPath.row].displayName

		return cell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Receivers"
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let myLabel = UILabel()
		myLabel.frame = CGRect(x: 20, y: 8, width: 320, height: 20)
		myLabel.font = UIFont.systemFont(ofSize: 42, weight: .heavy)
		myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
		myLabel.sizeToFit()

		let headerView = UIView()
		headerView.addSubview(myLabel)

		return headerView
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 64 
	}

}
