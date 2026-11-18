//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by joker on 2023/5/17.
//

import UserNotifications
import Foundation

/// 通知服务扩展（NSE）。
///
/// 诊断类工具的目标是「看到 APNs 实际送来的内容」，因此这里**不改写通知内容**：
/// 扩展只做一件事——把 `userInfo` 原样存到 App Group，交给 App 展示。
///
/// （Apple 模板默认会改标题等字段，那会让"收到的 payload 是否被改过"变得不可判断。）
class NotificationService: UNNotificationServiceExtension {

    /// 与 Tester App 共享的 App Group（见两个 target 的 entitlements）
    private static let appGroup = "group.com.joker.APNsHelper.tester"
    private static let payloadKey = "received_notification_payload"

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        Self.savePayload(request.content.userInfo)

        // 原样透传：不做任何修改
        if let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // MARK: - 保存原始 payload

    private static func savePayload(_ userInfo: [AnyHashable: Any]) {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }

        let dictionary: [String: Any] = userInfo.reduce(into: [:]) { result, element in
            result["\(element.key)"] = element.value
        }

        let record: [String: Any] = [
            "payload": dictionary,
            "receivedAt": Date().timeIntervalSince1970
        ]

        guard
            let data = try? JSONSerialization.data(withJSONObject: record, options: [.prettyPrinted, .sortedKeys]),
            let jsonString = String(data: data, encoding: .utf8)
        else {
            return
        }

        defaults.set(jsonString, forKey: payloadKey)
    }
}
