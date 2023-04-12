//
//  AppDelegate+UNUserNotification.swift
//  APNs Helper
//
//  Created by joker on 2023/4/6.
//

import UIKit
import UserNotifications

extension AppDelegate {
    
    func setupUNUserNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {_,_ in }
        UNUserNotificationCenter.current().delegate = UNUserNotificationManager.shared
        UIApplication.shared.registerForRemoteNotifications()
    }
}


extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenHexString = deviceToken.hexString
        UNUserNotificationManager.shared.deviceTokenSubject.send(deviceTokenHexString)
        UNUserNotificationManager.shared.deviceTokenSubject.send(completion: .finished)
        print("device token: \(deviceTokenHexString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("register device token failed. \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if userInfo.keys.contains("aps"), let aps = userInfo["aps"] as? [AnyHashable: Any], aps.keys.count == 1, aps.keys.contains("content-available"), let contentAvailable = aps["content-available"] as? Bool, contentAvailable {
            UNUserNotificationManager.shared.backgroundNotificationSubject.send("🔊 Background Notification Received")
        }
        
        completionHandler(.newData)
    }
}
