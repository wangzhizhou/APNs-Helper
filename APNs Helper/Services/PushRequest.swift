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
    ) throws -> APNSRequest<RawPayloadNotification> {
        let rawBody = payload.encodedData() ?? Data("{}".utf8)
        return try make(config: config, message: RawPayloadNotification(rawBody: rawBody, payload: payload))
    }

    private static func make(
        config: Config,
        message: RawPayloadNotification
    ) throws -> APNSRequest<RawPayloadNotification> {
        // topic / device token 都会进入 HTTP 头或 URL 路径，必须是 APNs 规范内的字符
        // （参考 swift-nio-http2 GHSA-q3g2-m552-3r9c：头值缺少 CR/LF 校验）
        let topic = config.pushType.topic(forBundleID: config.appBundleID)
        let deviceToken = config.pushType.deviceToken(in: config)
        try validatedHeaderValue(topic, name: "apns-topic")
        try validatedDeviceToken(deviceToken)

        return APNSRequest(
            message: message,
            deviceToken: deviceToken,
            pushType: config.pushType.type,
            expiration: config.pushType.expiration,
            priority: config.pushType.priority,
            apnsID: nil,
            topic: topic,
            collapseID: nil
        )
    }

    // MARK: - 输入校验

    /// topic 只允许域名/包名常用字符，禁止空格、CR、LF 等
    @discardableResult
    private static func validatedHeaderValue(_ value: String, name: String) throws -> String {
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_")
        guard !value.isEmpty, value.unicodeScalars.allSatisfy(allowed.contains)
        else {
            throw PushRequestError.unsafeHeaderValue(name: name, value: value)
        }
        return value
    }

    /// device token 必须是十六进制串
    @discardableResult
    private static func validatedDeviceToken(_ token: String) throws -> String {
        let hex = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        guard !token.isEmpty, token.unicodeScalars.allSatisfy(hex.contains)
        else {
            throw PushRequestError.unsafeHeaderValue(name: "device-token", value: token)
        }
        return token
    }
}

enum PushRequestError: LocalizedError, Equatable {
    case unsafeHeaderValue(name: String, value: String)

    var errorDescription: String? {
        switch self {
        case .unsafeHeaderValue(let name, let value):
            return "\(name) 含有非法字符：\(value.maskedForLog)"
        }
    }
}
