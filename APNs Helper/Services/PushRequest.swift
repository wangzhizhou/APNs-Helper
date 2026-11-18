//
//  PushRequest.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import Foundation
import APNS
import APNSCore

/// 把「用户配置 + 编辑器里的 JSON」翻译成发给 APNs 的请求。
///
/// 抽成独立类型的原因：请求头（push-type / topic / priority / expiration）是极易出错的
/// 协议细节，而 `APNsService` 里混着网络与 UI 状态，无法直接单测。
enum PushRequest {

    /// APNs 的 `apns-topic`、`apns-push-type` 等头信息全部由 `Config` 推导。
    static func make(config: Config, payload: JSONValue) -> APNSRequest<RawPayloadNotification> {
        APNSRequest(
            message: RawPayloadNotification(payload: payload),
            deviceToken: config.pushType.deviceToken(in: config),
            pushType: config.pushType.type,
            expiration: config.pushType.expiration,
            priority: config.pushType.priority,
            apnsID: nil,
            topic: config.pushType.topic(forBundleID: config.appBundleID),
            collapseID: nil
        )
    }
}
