//
//  AppDelegate+UNUserNotification.swift
//  APNs Helper
//
//  Created by joker on 2023/4/6.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

import UserNotifications

extension AppDelegate {

    func setupUNUserNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {_, _ in }
        UNUserNotificationCenter.current().delegate = UNUserNotificationManager.shared

#if canImport(UIKit)
        UIApplication.shared.registerForRemoteNotifications()
#endif

#if canImport(AppKit)
        NSApplication.shared.registerForRemoteNotifications()
#endif
    }
}

extension AppDelegate {
#if canImport(UIKit)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenHexString = deviceToken.hexString
        UNUserNotificationManager.shared.deviceTokenSubject.send(deviceTokenHexString)

        "device token: \(deviceTokenHexString)".printDebugInfo()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        "register device token failed. \(error.localizedDescription)".printDebugInfo()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        if userInfo.keys.contains("aps"), let aps = userInfo["aps"] as? [AnyHashable: Any], aps.keys.count == 1,
            aps.keys.contains("content-available"), let contentAvailable = aps["content-available"] as? Bool, contentAvailable {
            UNUserNotificationManager.shared.backgroundNotificationSubject.send("🔊 Background Notification Received")
        }

        completionHandler(.newData)
    }
#endif

#if canImport(AppKit)
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenHexString = deviceToken.hexString
        UNUserNotificationManager.shared.deviceTokenSubject.send(deviceTokenHexString)
        UNUserNotificationManager.shared.deviceTokenSubject.send(completion: .finished)

        "device token: \(deviceTokenHexString)".printDebugInfo()
    }

    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        "register device token failed. \(error.localizedDescription)".printDebugInfo()
    }

    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String: Any]) {
        if userInfo.keys.contains("aps"), let aps = userInfo["aps"] as? [AnyHashable: Any], aps.keys.count == 1,
            aps.keys.contains("content-available"),
            let contentAvailable = aps["content-available"] as? Bool, contentAvailable {
            UNUserNotificationManager.shared.backgroundNotificationSubject.send("🔊 Background Notification Received")
        }
    }
#endif
}
