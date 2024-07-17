//
//  UNUserNotificationManager.swift
//  APNs Helper
//
//  Created by joker on 2023/4/12.
//

import Foundation
import UserNotifications
@preconcurrency import Combine

final class UNUserNotificationManager: NSObject, Sendable {

    // 单例实现
    static let shared = UNUserNotificationManager()
    private override init() {}

    // 功能实现
    let deviceTokenSubject = PassthroughSubject<String, Never>()
    let backgroundNotificationSubject = PassthroughSubject<String, Never>()
}

extension UNUserNotificationManager: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .list, .banner])
    }
}
