//
//  AppDelegate.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 28/11/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import UIKit
import AVFoundation

/// The application delegate, used for application state event handling
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	/// The application window
	var window: UIWindow?
}

// MARK: - Application lifecycle
extension AppDelegate {
	/// Tells the delegate that the launch process is almost done and the app is almost ready to run.
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

        // Prevent the app from going to sleep mode
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Make sure User defaults are Up to date
		DataFlowDefaults.check()

		// Init the audio Session and set up its parameters
        setupAudioSession()

		return true
	}

	/// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	func applicationWillResignActive(_ application: UIApplication) {
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

		UIApplication.shared.isIdleTimerDisabled = true
	}

	/// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	func applicationDidEnterBackground(_ application: UIApplication) {
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

		UIApplication.shared.isIdleTimerDisabled = true
	}


	/// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	func applicationWillEnterForeground(_ application: UIApplication) {
	}


	/// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	func applicationDidBecomeActive(_ application: UIApplication) {
	}


	/// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	func applicationWillTerminate(_ application: UIApplication) {
		UIApplication.shared.isIdleTimerDisabled = false
	}
}

// MARK: - Application Audio Session
extension AppDelegate {
    /// Init the audio session, sets its category, mode and options and make it active
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        try! audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowAirPlay, .allowBluetooth, .defaultToSpeaker])
        
        try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
}

