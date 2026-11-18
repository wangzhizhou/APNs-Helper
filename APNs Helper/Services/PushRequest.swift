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

    /// - Parameter payloadData: **逐字节**作为请求体发出（见 `RawBodyEncoder`）
    static func make(
        config: Config,
        payloadData: Data
    ) throws -> APNSRequest<RawPayloadNotification> {
        try make(config: config, message: RawPayloadNotification(payloadData: payloadData))
    }

    /// 由已解析的 JSON 构造（测试与预览使用）。
    static func make(
        config: Config,
        payload: JSONValue
    ) -> APNSRequest<RawPayloadNotification> {
        let rawBody = payload.encodedData() ?? Data("{}".utf8)
        return make(config: config, message: RawPayloadNotification(rawBody: rawBody, payload: payload))
    }

    private static func make(
        config: Config,
        message: RawPayloadNotification
    ) -> APNSRequest<RawPayloadNotification> {
        APNSRequest(
            message: message,
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
