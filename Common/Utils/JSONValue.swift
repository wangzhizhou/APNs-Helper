//
//  JSONValue.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import Foundation

/// 一个最小的 JSON 值模型。
///
/// APNs Helper 允许用户直接编辑完整的推送 Payload，发送时需要把这段 JSON **原样**作为
/// HTTP Body 交给 APNs。`JSONEncoder` 无法直接输出"原始字节"，所以这里把用户 JSON 解析成
/// `JSONValue`，再由它自己实现 `encode(to:)`，从而保证语义完全一致的往返（round-trip）。
indirect enum JSONValue: Equatable, Sendable {
    case object([String: JSONValue])
    case array([JSONValue])
    case string(String)
    case number(JSONNumber)
    case bool(Bool)
    case null
}

/// 数字需要区分整型与浮点：`Int64` 走 `Double` 会丢精度（如毫秒时间戳、雪花 ID）。
enum JSONNumber: Equatable, Sendable {
    case int(Int64)
    case double(Double)
}

// MARK: - 解析

extension JSONValue {

    /// 从 JSON 数据解析，非法 JSON 返回 `nil`。
    init?(jsonData: Data) {
        guard let object = try? JSONSerialization.jsonObject(
            with: jsonData,
            options: [.fragmentsAllowed]
        ), let value = JSONValue(any: object)
        else {
            return nil
        }
        self = value
    }

    /// 从 JSON 字符串解析，非法 JSON 返回 `nil`。
    init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        self.init(jsonData: data)
    }

    private init?(any: Any) {
        switch any {
        case is NSNull:
            self = .null
        case let nsNumber as NSNumber:
            self = JSONValue.scalar(from: nsNumber)
        case let string as String:
            self = .string(string)
        case let array as [Any]:
            guard let values = JSONValue.array(from: array) else { return nil }
            self = .array(values)
        case let dictionary as [String: Any]:
            guard let values = JSONValue.object(from: dictionary) else { return nil }
            self = .object(values)
        default:
            return nil
        }
    }

    private static func scalar(from nsNumber: NSNumber) -> JSONValue {
        if CFGetTypeID(nsNumber) == CFBooleanGetTypeID() {
            return .bool(nsNumber.boolValue)
        }
        return CFNumberIsFloatType(nsNumber)
            ? .number(.double(nsNumber.doubleValue))
            : .number(.int(nsNumber.int64Value))
    }

    private static func array(from array: [Any]) -> [JSONValue]? {
        var values: [JSONValue] = []
        values.reserveCapacity(array.count)
        for element in array {
            guard let value = JSONValue(any: element) else { return nil }
            values.append(value)
        }
        return values
    }

    private static func object(from dictionary: [String: Any]) -> [String: JSONValue]? {
        var values: [String: JSONValue] = [:]
        values.reserveCapacity(dictionary.count)
        for (key, element) in dictionary {
            guard let value = JSONValue(any: element) else { return nil }
            values[key] = value
        }
        return values
    }
}

// MARK: - 编码

extension JSONValue: Encodable {

    func encode(to encoder: Encoder) throws {
        switch self {
        case .object(let values):
            var container = encoder.container(keyedBy: DynamicCodingKey.self)
            for (key, value) in values {
                guard let codingKey = DynamicCodingKey(stringValue: key) else {
                    throw EncodingError.invalidValue(
                        key,
                        .init(codingPath: encoder.codingPath, debugDescription: "Invalid JSON key: \(key)")
                    )
                }
                try container.encode(value, forKey: codingKey)
            }
        case .array(let values):
            var container = encoder.unkeyedContainer()
            for value in values {
                try container.encode(value)
            }
        case .string(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string)
        case .number(.int(let int)):
            var container = encoder.singleValueContainer()
            try container.encode(int)
        case .number(.double(let double)):
            var container = encoder.singleValueContainer()
            try container.encode(double)
        case .bool(let bool):
            var container = encoder.singleValueContainer()
            try container.encode(bool)
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
}

// MARK: - 便利访问

extension JSONValue {

    /// 序列化成 `Data`（默认不排序 key，保持解析时的稳定顺序由 `JSONEncoder` 决定）。
    func encodedData(prettyPrinted: Bool = false) -> Data? {
        let encoder = JSONEncoder()
        if prettyPrinted {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        }
        return try? encoder.encode(self)
    }

    var objectValue: [String: JSONValue]? {
        guard case .object(let values) = self else { return nil }
        return values
    }

    /// 用于 `aps` 之类固定层级的下标访问。
    subscript(key: String) -> JSONValue? {
        objectValue?[key]
    }
}

/// 以字符串为 key 的编码容器 key，用于把 `[String: JSONValue]` 原样编码成 JSON 对象。
struct DynamicCodingKey: CodingKey {

    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}
