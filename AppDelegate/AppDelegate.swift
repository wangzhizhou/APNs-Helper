//
//  AppDelegate.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupUNUserNotification()
        setupPushKitAndCallKit()
        return true
    }
}
