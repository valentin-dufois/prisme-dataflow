//
//  Notifications.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 01/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation

/// All the notifications used by the app
enum Notifications: String {
	/// Sent whe the settings have just been updated
	case settingsUpdated

	/// Sent when the user wants to change to emitter
	case switchToEmitter

	/// Sent when the user wants to change to receiver
	case switchToReceiver

	/// Sent when the audio started playing
	case startedPlaying

	/// Sent when the audio stopped playing
	case stoppedPlaying

	/// Gives the name of the notification in the `NSNotification.Name` format
	var name:Notification.Name {
		return Notification.Name(self.rawValue)
	}
}
