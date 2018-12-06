//
//  SocketDelegate.swift
//  dataflow
//
//  Created by Valentin Dufois on 05/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

protocol SocketDelegate {

	/// Called when the socket succesfully connect
	///
	/// - Parameter _: The socket
	func socketDidConnect(_ socket:Socket)

	/// Called when the socked gets disconnected, either by a call to `Socket.disconnect`
	/// or 'Socket.reconnect()` or if the connection gets lost.
	///
	/// - Parameters:
	///   - socket: The current socket
	///   - error: The error if any
	func socketDidDisconnect(_ socket:Socket, error:Error?)

	/// Called when the socket receives data
	///
	/// - Parameters:
	///   - socket: The socket
	///   - receivedData: The received data
//	func socket(_ socket:Socket, receivedData:Data)
}
