//
//  String+Utils.swift
//  APNs Helper
//
//  Created by joker on 2023/4/6.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension String {

    static let empty = ""

    var trimmed: String { self.trimmingCharacters(in: .whitespacesAndNewlines) }

    func copyToPasteboard() {
#if os(iOS)
        UIPasteboard.general.string = self
#elseif os(macOS)
        NSPasteboard.general.declareTypes([.string], owner: nil)
        let ret = NSPasteboard.general.setString(self, forType: .string)
        assert(ret, "write string to paste board failed!")
#endif
        NotificationCenter.default.post(name: .APNSHelperStringCopyedToPastedboard, object: self)
    }

    func printDebugInfo() {
#if DEBUG
        print("[DEBUG_INFO]: \(self)")
#endif
    }
}

extension String {
    
    var floatValue: Float? {
        return Float(self)
    }
    
    var doubleValue: Double? {
        return Double(self)
    }
    
    var intValue: Int? {
        return Int(self)
    }
}

extension Notification.Name {
    static let APNSHelperStringCopyedToPastedboard = Notification.Name("APNSHelperStringCopyedToPastedboard")
}

// MARK: - 日志脱敏

extension String {

    /// 隐去 PEM 私钥内容（`.p8` 等），保留首尾标记便于识别。
    var maskedPEM: String {
        replacingMatches(
            of: "(-----BEGIN [A-Z ]*PRIVATE KEY-----)([\\s\\S]*?)(-----END [A-Z ]*PRIVATE KEY-----)",
            with: "$1 [redacted] $3"
        )
    }

    /// 日志用脱敏：PEM 内容 + device token 这类长十六进制串。
    ///
    /// 仅用于错误信息等「可能夹带凭据」的文本；发送/接收的 Payload 日志不做处理，
    /// 否则会破坏「逐字节对照」的诊断价值。
    var maskedForLog: String {
        maskedPEM.replacingMatches(of: "\\b[0-9a-fA-F]{32,}\\b") { match in
            let prefix = String(match.prefix(8))
            return "\(prefix)…"
        }
    }

    private func replacingMatches(
        of pattern: String,
        with template: String
    ) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return self }
        let range = NSRange(startIndex..., in: self)
        return regex.stringByReplacingMatches(in: self, range: range, withTemplate: template)
    }

    private func replacingMatches(
        of pattern: String,
        transform: (String) -> String
    ) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return self }
        let matches = regex.matches(in: self, range: NSRange(startIndex..., in: self))
        guard !matches.isEmpty else { return self }

        var result = ""
        var cursor = startIndex
        for match in matches {
            guard let range = Range(match.range, in: self) else { continue }
            result += self[cursor..<range.lowerBound]
            result += transform(String(self[range]))
            cursor = range.upperBound
        }
        result += self[cursor...]
        return result
    }
}
