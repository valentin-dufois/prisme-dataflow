//
//  Socket.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import SwiftSocket


// MARK: - Socket connection
extension Communicator {
	func connectToSocket() {
		guard !_isSocketConnected else { return }

		let url = DataFlowDefaults.serverURL.url!.absoluteString
		let port = Int32(DataFlowDefaults.serverPort.integer!)

		_socketClient = TCPClient(address: url, port: port)

		switch _socketClient.connect(timeout: 10) {
		case .success:
			_isSocketConnected = true
			NotificationCenter.default.post(name: Notifications.socketConnected.name, object: nil)
		case .failure(let error):
			_isSocketConnected = false
			print("Connection failed : \(error.localizedDescription)")
			NotificationCenter.default.post(name: Notifications.socketDisconnected.name, object: nil)
		}
	}
	
	func emitToSocket(data: Data) {
		guard _isSocketConnected else { return }

		switch _socketClient.send(data: data) {
		case .success:
			_ = _socketClient.send(string: "\n")
		case .failure(_):
			_isSocketConnected = false
			NotificationCenter.default.post(name: Notifications.socketDisconnected.name, object: nil)
		}
	}

	func reconnectToSocket() {
		// Close the current connection if any
		deconnectFromSocket()

		// Open a new connection
		connectToSocket()
	}

	func deconnectFromSocket() {
		guard _isSocketConnected else { return }

		_socketClient.close()
		_isSocketConnected = false
		NotificationCenter.default.post(name: Notifications.socketDisconnected.name, object: nil)
	}
}
