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
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
    }
}


extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenHexString = deviceToken.hexString
        APNsHelperApp.model.thisAppConfig.deviceToken = deviceTokenHexString
        print("device token: \(deviceTokenHexString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("register device token failed. \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if userInfo.keys.contains("aps"), let aps = userInfo["aps"] as? [AnyHashable: Any], aps.keys.count == 1, aps.keys.contains("content-available"), let contentAvailable = aps["content-available"] as? Bool, contentAvailable {
            APNsHelperApp.model.toastMessage = "🔊 Background Notification Received"
        }
        
        completionHandler(.newData)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .list, .banner])
    }
    
}
