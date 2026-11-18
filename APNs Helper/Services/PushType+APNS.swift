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
