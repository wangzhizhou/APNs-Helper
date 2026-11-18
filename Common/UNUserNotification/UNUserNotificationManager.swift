//
//  UNUserNotificationManager.swift
//  APNs Helper
//
//  Created by joker on 2023/4/12.
//

import Foundation
import UserNotifications
import Combine

/// 统一处理「收到的通知」，把 Payload 完整地暴露给界面，便于对照发送内容做诊断。
class UNUserNotificationManager: NSObject {

    // 单例实现
    nonisolated(unsafe) static let shared = UNUserNotificationManager()
    private override init() {}

    // 功能实现
    /// 注册成功后拿到的 device token（hex 字符串）。
    let deviceTokenSubject = PassthroughSubject<String, Never>()

    /// 收到的通知内容（格式化后的 JSON），用于在界面日志中查看。
    let backgroundNotificationSubject = PassthroughSubject<String, Never>()

    /// 注册远程通知过程中的错误/状态，用于在界面日志中定位「收不到推送」的原因。
    let errorSubject = PassthroughSubject<String, Never>()
}

extension UNUserNotificationManager: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        publishPayload(of: notification)
        completionHandler([.badge, .sound, .list, .banner])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        publishPayload(of: response.notification)
        completionHandler()
    }

    /// 把 `userInfo` 反射成 JSON 字符串；解析不出来时退回 Swift 描述。
    private func publishPayload(of notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        backgroundNotificationSubject.send(userInfo.jsonString ?? "\(userInfo)")
    }
}
