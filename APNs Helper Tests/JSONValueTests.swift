//
//  JSONValueTests.swift
//  APNs Helper Tests
//
//  Created by joker on 2025/11/17.
//

import Foundation
import Testing

@Suite("JSONValue")
struct JSONValueTests {

    @Test("非法 JSON 解析失败")
    func invalidJSONReturnsNil() {
        #expect(JSONValue(jsonString: "{not json") == nil)
        #expect(JSONValue(jsonString: "") == nil)
        #expect(JSONValue(jsonData: Data([0x00, 0x01])) == nil)
    }

    @Test("标量解析")
    func parsesScalars() throws {
        #expect(JSONValue(jsonString: "null") == .null)
        #expect(JSONValue(jsonString: "true") == .bool(true))
        #expect(JSONValue(jsonString: "\"hello\"") == .string("hello"))
        #expect(JSONValue(jsonString: "42") == .number(.int(42)))
        #expect(JSONValue(jsonString: "1.5") == .number(.double(1.5)))
        #expect(JSONValue(jsonString: "\"中文 emoji 🚀\"") == .string("中文 emoji 🚀"))
    }

    @Test("大整数不丢精度")
    func keepsInt64Precision() throws {
        let raw = #"{"id": 9223372036854775807}"#
        let value = try #require(JSONValue(jsonString: raw))
        #expect(value["id"] == .number(.int(Int64.max)))
    }

    @Test("嵌套结构往返一致")
    func roundTripsNestedPayload() throws {
        let raw = """
        {
          "aps": {
            "alert": { "title": "Title", "body": "Body" },
            "badge": 3,
            "sound": "default",
            "mutable-content": 1,
            "interruption-level": "time-sensitive"
          },
          "custom": {
            "flag": true,
            "ratio": 0.25,
            "list": [1, 2, 3, "four", null, { "deep": "value" }]
          }
        }
        """
        let value = try #require(JSONValue(jsonString: raw))
        let encoded = try #require(value.encodedData())
        let decoded = try #require(JSONValue(jsonData: encoded))
        #expect(decoded == value)

        // 与原始 JSON 语义一致
        let originalObject = try JSONSerialization.jsonObject(with: Data(raw.utf8)) as? NSDictionary
        let encodedObject = try JSONSerialization.jsonObject(with: encoded) as? NSDictionary
        #expect(originalObject == encodedObject)
    }

    @Test("null、bool 与数字保持类型")
    func preservesTypes() throws {
        let value = try #require(JSONValue(jsonString: #"{"a": null, "b": false, "c": 0, "d": 0.0}"#))
        let encoded = try #require(value.encodedData())
        let object = try #require(try JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        #expect(object["a"] is NSNull)
        #expect(object["b"] as? Bool == false)
        #expect(object["c"] as? Int == 0)
        #expect(object["d"] as? Double == 0.0)
    }

    @Test("顶层数组同样支持")
    func supportsTopLevelArray() throws {
        let value = try #require(JSONValue(jsonString: "[1, 2, 3]"))
        #expect(value == .array([.number(.int(1)), .number(.int(2)), .number(.int(3))]))
        #expect(value.encodedData() != nil)
    }
}
