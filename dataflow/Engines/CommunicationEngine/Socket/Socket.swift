//
//  Socket.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import SwiftSocket


/// Represent a network socket, allowing for sending data to a remote socket
class Socket {
	// MARK: Properties

	/// The socket client
	private var _socket: TCPClient!

	/// Tell if the socket is connected
	private var _isSocketConnected: Bool = false

	/// Current connection status of the socket. True if connected
	public var connected: Bool {
		return _isSocketConnected
	}

	/// The socket delegate
	public var delegate:SocketDelegate?

	/// The socket url
	private var _url:String!

	/// The socket port
	private var _port:Int32!

	/// Open a connection
	///
	/// - Parameters:
	///   - url: URL of the socket
	///   - port: Port of the socket
	func connect(to url: String, port: Int32) {
		// Make sure the socket isn't already opened
		guard !self.connected else {
			print("[Socket.connect] Socket is already connected to \(_socket.address):\(_socket.port)")
			return
		}

		_url = url
		_port = port

		// Create the client
		_socket = TCPClient(address: _url, port: _port)

		// Open the client and check for success or failure
		switch _socket.connect(timeout: 10) {
		case .success:
			// Socket opened successfully
			_isSocketConnected = true
			self.delegate?.socketDidConnect(self)

		case .failure(let error):
			// Failed to open socket
			_isSocketConnected = false
			self.delegate?.socketDidDisconnect(self, error: error)
		}
	}
	
	/// Emit the given data on the socket
	///
	/// - Parameter data: Data to send
	func emit(data: Data) {
		guard self.connected else {
			print("[Socket.emit] Socket is not connected")
			return
		}

		switch _socket.send(data: data) {
		case .success:
			_ = _socket.send(string: "\n")

		case .failure(let error):
			_isSocketConnected = false
			self.delegate?.socketDidDisconnect(self, error: error)
		}
	}

	/// Read from the socket. if no data can be read, this will return nil
	///
	/// - Parameter count: Number of bytes to read from the socket
	/// - Returns: The received data or nil if no data is present
	func read(count: Int) -> Data? {
		guard let bytes = _socket.read(count) else { return nil }

		return Data(bytes: bytes)
	}

	/// Disconnect then reconnect the socket on the same url and port
	func reconnect() {
		// Close the current connection if any
		disconnect()

		// Open a new connection
		connect(to: _url, port: _port)
	}

	/// Disconnect from the socket. The socket be re-opened on the same url and port
	/// by calling `Socket.reconnect()`
	func disconnect() {
		guard self.connected else { return }

		_socket.close()
		_isSocketConnected = false

		self.delegate?.socketDidDisconnect(self, error: nil)
	}

	/// Make sure to properly close the connection
	deinit {
		disconnect()
	}
}
