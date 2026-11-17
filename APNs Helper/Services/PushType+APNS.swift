//
//  PushType+APNS.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import Foundation
import APNS
import APNSCore

extension PushType {

    var type: APNSPushType {
        switch self {
        case .alert:
            return .alert
        case .background:
            return .background
        case .voip:
            return .voip
        case .fileprovider:
            return .fileprovider
        case .location:
            return .location
        case .liveactivity:
            return .liveactivity
        }
    }

    /// `APNSPriority` 的初始化器不对外，因此从 `priorityValue` 反向映射。
    var priority: APNSPriority {
        switch priorityValue {
        case APNSPriority.immediately.rawValue:
            return .immediately
        case APNSPriority.consideringDevicePower.rawValue:
            return .consideringDevicePower
        default:
            return .prioritizeDevicePower
        }
    }

    var expiration: APNSNotificationExpiration {
        usesImmediateExpiration ? .immediately : .none
    }
}

extension APNServerEnv {

    var env: APNSEnvironment {
        switch self {
        case .sandbox:
            return .development
        case .production:
            return .production
        }
    }
}

/// 把用户在编辑器里写的 JSON 原样作为 Body 发送。
///
/// 上游 APNSwift 只提供强类型的 `APNSXxxNotification`，本 App 需要透传任意 Payload，
/// 因此这里用一个薄封装把任意 JSON 作为 `APNSMessage` 交给 `APNSClient.send(_:)`。
struct RawPayloadNotification: APNSMessage {
    let payload: JSONValue

    func encode(to encoder: Encoder) throws {
        try payload.encode(to: encoder)
    }
}
