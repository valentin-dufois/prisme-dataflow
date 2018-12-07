//
//  Notifications.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 01/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

enum Notifications: String {
	case settingsUpdated
	case switchToEmitter
	case switchToReceiver
    
    case debug

	var name:Notification.Name {
		return Notification.Name(self.rawValue)
	}
}
