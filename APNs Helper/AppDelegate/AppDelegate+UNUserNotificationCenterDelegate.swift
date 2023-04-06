//
//  AppDelegate+UNUserNotificationCenterDelegate.swift
//  APNs Helper
//
//  Created by joker on 2023/4/6.
//

import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .list, .banner])
    }
    
}
