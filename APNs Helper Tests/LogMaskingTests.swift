//
//  LogMaskingTests.swift
//  APNs Helper Tests
//
//  Created by joker on 2025/11/17.
//

import Foundation
import Testing

@Suite("日志脱敏")
struct LogMaskingTests {

    private let privateKey = """
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgViPOgSdnJxJ2gXfH
    -----END PRIVATE KEY-----
    """

    @Test("PEM 内容被隐去，首尾标记保留")
    func masksPEM() {
        let masked = "key: \(privateKey)".maskedPEM
        #expect(masked.contains("[redacted]"))
        #expect(!masked.contains("MIGHAgEAMBMGByqGSM49AgEG"))
        #expect(masked.contains("-----BEGIN PRIVATE KEY-----"))
        #expect(masked.contains("-----END PRIVATE KEY-----"))
    }

    @Test("长十六进制串（device token）只保留前 8 位")
    func masksToken() {
        let token = String(repeating: "a1b2c3d4", count: 8)  // 64 位 hex
        let masked = "deviceToken=\(token)".maskedForLog
        #expect(masked == "deviceToken=a1b2c3d4…")
    }

    @Test("短内容与普通文本不受影响")
    func leavesPlainTextAlone() {
        let text = "Send Push Success! apnsID=0A1B2C3D"
        #expect(text.maskedForLog == text)
        #expect("中文字符 abc123".maskedForLog == "中文字符 abc123")
    }

    @Test("Payload 日志只隐去 PEM，不动其它内容")
    func payloadKeepsContent() {
        let payload = #"{"aps":{"alert":"hi"},"hash":"deadbeefdeadbeefdeadbeefdeadbeef"}"#
        #expect(payload.maskedPEM == payload)
    }
}
