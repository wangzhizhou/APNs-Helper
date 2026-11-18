//
//  RawBody.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import Foundation
import APNS
import APNSCore
import NIOCore

/// 把用户写的 JSON **逐字节**写进请求体。
///
/// 默认 `JSONEncoder` 会重新序列化（键序变化、`2.0` 会变成 `2`），对诊断类工具有误导性：
/// 排查"服务端发的和我发的为什么不一致"时，必须保证编辑器里的内容原样上线。
/// 这里通过 APNSwift 的 `APNSJSONEncoder` 扩展点直接写入原始字节；
/// `JSONValue` 仍用于校验与日志，但不参与编码。
struct RawBodyEncoder: APNSJSONEncoder {

    func encode<T: Encodable>(_ value: T, into buffer: inout ByteBuffer) throws {
        if let rawPayload = value as? RawPayloadNotification {
            buffer.writeBytes(rawPayload.rawBody)
            return
        }
        // 其它消息（理论上不会出现）退回默认编码，保持行为可预期
        try JSONEncoder().encode(value, into: &buffer)
    }
}

/// 透传用户 Payload 的消息类型。
///
/// - `rawBody`：原始字节，真正发送的内容
/// - `payload`：解析后的 JSON，用于校验/日志/测试断言
struct RawPayloadNotification: APNSMessage {

    let rawBody: Data
    let payload: JSONValue

    init(rawBody: Data, payload: JSONValue) {
        self.rawBody = rawBody
        self.payload = payload
    }

    init(payloadData: Data) throws {
        guard let payload = JSONValue(jsonData: payloadData) else {
            throw APNsPayloadError.invalidJSON
        }
        self.init(rawBody: payloadData, payload: payload)
    }

    /// 仅在使用默认编码器时生效（`RawBodyEncoder` 会直接写 `rawBody`）
    func encode(to encoder: Encoder) throws {
        try payload.encode(to: encoder)
    }
}

enum APNsPayloadError: LocalizedError {
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return "Payload is not valid JSON"
        }
    }
}
