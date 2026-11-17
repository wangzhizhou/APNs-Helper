//
//  PushType.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import Foundation

/// 支持的推送类型。
///
/// 这里只保留与 APNs 传输层无关的领域逻辑（Topic 规则、优先级数值、Token 选择），
/// 到 `APNSCore` 类型（`APNSPushType` / `APNSPriority` / `APNSNotificationExpiration`）
/// 的映射放在 `PushType+APNS.swift`，这样单元测试不需要链接 NIO 等底层依赖。
enum PushType: String, CaseIterable, Codable {
    case alert
    case background
    case voip
    case fileprovider
    case location
    case liveactivity

    /// APNs Topic 的后缀，`nil` 表示直接用 BundleID。
    /// 参考 https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns
    var topicSuffix: String? {
        switch self {
        case .alert, .background:
            return nil
        case .voip:
            return ".voip"
        case .fileprovider:
            return ".pushkit.fileprovider"
        case .location:
            return ".location-query"
        case .liveactivity:
            return ".push-type.liveactivity"
        }
    }

    func topic(forBundleID bundleID: String) -> String {
        bundleID + (topicSuffix ?? "")
    }

    /// `apns-priority` 头的数值。
    var priorityValue: Int {
        switch self {
        case .alert, .voip, .location, .liveactivity:
            return 10
        case .background, .fileprovider:
            // APNs 对这两类推送只接受 5，否则会返回错误。
            return 5
        }
    }

    /// `location` 推送不能携带 `apns-expiration`。
    var usesImmediateExpiration: Bool {
        switch self {
        case .location:
            return false
        default:
            return true
        }
    }

    /// 该推送类型对应的设备 Token（不同通道的 Token 不能混用）。
    func deviceToken(in config: Config) -> String {
        switch self {
        case .alert, .background:
            return config.deviceToken
        case .voip:
            return config.pushKitVoIPToken
        case .fileprovider:
            return config.pushKitFileProviderToken
        case .location:
            return config.locationPushServiceToken
        case .liveactivity:
            return config.liveActivityPushToken
        }
    }
}
