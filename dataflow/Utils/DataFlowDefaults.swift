//
//  DataFlowDefaults.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

/// Easy access to the application UserDefaults
enum DataFlowDefaults:String {
	/// The current version of the defaults
	///
	/// Int
	case version

	/// The URL to the socket server
	///
	/// URL
	case serverURL

	/// The port for the socket server
	///
	/// Int
	case serverPort

	/// The current type of the app : Emitter or Receiver
	///
	/// String
	case appType

	/// The name of the peer service used by the app
	///
	/// String
	case peerServiceName

	/// Audio gain to put on the mic
	///
	/// Double
    case audioGain
}

extension DataFlowDefaults {
	/// Gets the value as an URL
	var url: URL? {
		return UserDefaults.standard.url(forKey: self.rawValue)
	}

	/// Gets the value as an Int
	var integer: Int? {
		return UserDefaults.standard.integer(forKey: self.rawValue)
	}

	/// Gets the value as a Double
    var double: Double? {
        return UserDefaults.standard.double(forKey: self.rawValue)
    }

	/// Gets the value as a String
	var string: String? {
		return UserDefaults.standard.string(forKey: self.rawValue)
	}

	/// Sets the value as an URL
	func set(value: URL) -> Void {
		UserDefaults.standard.set(value, forKey: self.rawValue)
	}


	/// Sets the value as an Int
	func set(value: Int) -> Void {
		UserDefaults.standard.set(value, forKey: self.rawValue)
	}

	/// Sets the value as a String
	func set(value: String) -> Void {
		UserDefaults.standard.set(value, forKey: self.rawValue)
	}

	/// Sets the value as a Double
    func set(value: Double) -> Void {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }

	/// Checks the Dataflow version and update the values if needed
    static func check() {
        let defaultVersion = 2
        
        // Set default values only if they are missing
        guard (DataFlowDefaults.version.integer ?? 0) != defaultVersion else { return }
        
        DataFlowDefaults.version.set(value: defaultVersion)
        DataFlowDefaults.serverURL.set(value: URL(string: "valentindufois.fr")!)
        DataFlowDefaults.serverPort.set(value: 1457)
        DataFlowDefaults.appType.set(value: "emitter")
        DataFlowDefaults.peerServiceName.set(value: "prisme-dataflow")
        DataFlowDefaults.audioGain.set(value: 1.0)
        
        print("User defaults set to default values")
    }
}
