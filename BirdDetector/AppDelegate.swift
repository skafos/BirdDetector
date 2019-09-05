//
//  AppDelegate.swift
//  BirdDetector
//
//  Created by Skafos on 9/5/19.
//  Copyright © 2019 Skafos LLC. All rights reserved.
//

import UIKit
import Skafos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set Skafos environment keys
        // You can find them under your App Settings tab @ https://dashboard.skafos.ai
        #if DEBUG
        // Use the DEV key if running in DEBUG mode
        let key = "{your-dev-key}"
        #else
        // Use the PROD key otherwise
        let key = "{your-prod-key}"
        #endif
        
        // Initialize Skafos
        Skafos.initialize(key, swizzle: true)
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

