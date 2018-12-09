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

	private var _multipeerServer: MultipeerServer!
	private var _clientStreams = [String:OutputStream]()

	override func viewDidLoad() {
        super.viewDidLoad()

		initMultipeer()
	}
    
    func initMultipeer() {
		if(_multipeerServer?.isRunning ?? false) {
			return()
		}

        // Create and start the server
        _multipeerServer = MultipeerServer(serviceName: DataFlowDefaults.peerServiceName.string!)
        _multipeerServer.delegate = self
        _multipeerServer.open()
        
        App.emitterStream = self
        print("[EmitterStreamController.initMultipeer] Multipeer server started")
    }

	/// Properly close the server
	func closeMultipeer() {
		_multipeerServer?.close()
	}

	// Make sure to properly close the server
	deinit {
		closeMultipeer()
	}
}


// MARK: Clients handling
extension EmitterStreamController {
	func clientConnected(peerID: MCPeerID) {
		guard _clientStreams[peerID.displayName] == nil else {
			print("[EmitterStreamController.clientConnected] A stream already exist for client \(peerID.displayName)")
			return
		}

		var outputStream: OutputStream!

		// Try to open the stream to the client
		do {
			outputStream = try _multipeerServer.makeStream(forPeer: peerID)
		} catch {
			fatalError("[EmitterStreamController.clientConnected] Could not create a stream for client \(peerID.displayName) : \(error.localizedDescription)")
		}

		// Schedule and open the streamq<
		outputStream.schedule(in: .current, forMode: .common)
		outputStream.open()

		// Finally, store it for later use
		_clientStreams[peerID.displayName] = outputStream
	}

	func clientDisconnected(peerID: MCPeerID) {
		guard let outputStream = _clientStreams[peerID.displayName] else {
			print("[EmitterStreamController.clientConnected] No stream to remove for \(peerID.displayName)")
			return
		}

		// Close the stream
		outputStream.close()

		// And remove it
		_clientStreams.removeValue(forKey: peerID.displayName)
	}
}


// MARK: Sending Data
extension EmitterStreamController: streamEmitterDelegate {
	func emit(data: Data) {
//        print("[streamEmitterDelegate.emit] Emitting to \(_clientStreams.count) clients")
		_clientStreams.forEach { (arg) in
			let (_, outputStream) = arg

			_ = data.withUnsafeBytes { dataPointer in
				outputStream.write(dataPointer, maxLength: data.count)
			}
		}
	}
}


extension EmitterStreamController: MultipeerDelegate {
	/// Automatically accept all incoming invitations
	func mpDevice(_ device: MultipeerDevice, shouldAcceptPeer peer: MCPeerID, withContext context: Data?) -> Bool {
		return true
	}

	/// Stop the app if we cannot start the server
	func mpDevice(_ device: MultipeerDevice, didNotStart error: Error) {
		fatalError("[EmitterStreamController] Could not start MultipeerServer : \(error.localizedDescription)")
	}

	/// Trigger a refresh of the table when a peer state changes
	func mpDevice(_ device: MultipeerDevice, peerStateChanged peer: MCPeerID, to state: MCSessionState) {
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}

		switch state {
		case .connected:
			clientConnected(peerID: peer)
		case .notConnected:
			clientDisconnected(peerID: peer)
		default: break;
		}
	}
}


// MARK: - UITableViewDelegate
extension EmitterStreamController /*: UITableViewDelegate*/ {
	/// Tells the number of section in the table
	///
	/// - Parameter tableView: The current tableView
	/// - Returns: The number of sections in the tableView
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	/// Tells the number of rows in the given section
	///
	/// - Parameters:
	///   - tableView: The current tableView
	///   - section: The current section
	/// - Returns: The number of rows in the current section
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _multipeerServer?.connectedPeers.count ?? 0
	}

	/// Gives the View for the cell
	///
	/// - Parameters:
	///   - tableView: The current tableView
	///   - indexPath: The index of the row to get the view for
	/// - Returns: The view for the row
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "receiverCell")!
		cell.textLabel?.text = _multipeerServer.connectedPeers[indexPath.row].displayName

		return cell
	}

	/// Tells the title of the given section
	///
	/// - Parameters:
	///   - tableView: The current tableView
	///   - section: The section number
	/// - Returns: The title of the section
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Receivers"
	}

	/// Gives the view for the specified header
	///
	/// - Parameters:
	///   - tableView: The current tableView
	///   - section: The section to get the header for
	/// - Returns: The View for the header
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

	/// Tells the height of the specified header view
	///
	/// - Parameters:
	///   - tableView: The current tableView
	///   - section: The current section
	/// - Returns: The height of the headers
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 64 
	}

}
