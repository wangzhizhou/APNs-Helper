//
//  AppDelegate.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

#if os(iOS)
import UIKit
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupUNUserNotification()
        setupPushKitAndCallKit()
        setupFileProvider()
        return true
    }
}
#elseif os(macOS)
import AppKit
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupUNUserNotification()
        setupPushKitAndCallKit()
        setupFileProvider()
    }
}
#endif
