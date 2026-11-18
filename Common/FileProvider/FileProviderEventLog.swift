//
//  FileProviderEventLog.swift
//  APNs Helper
//
//  Created by joker on 2025/11/18.
//

import Foundation

/// File Provider 相关事件记录。
///
/// File Provider 类型推送"发出去之后到底发生了什么"在设备上很难观察，
/// 因此把「扩展被调用」「域被注册」「App 收到推送」等事件写入 App Group，
/// 由 Tester App 读取展示（Tester 工具栏 → Show FileProvider Events）。
enum FileProviderEventLog {

    static let appGroup = "group.com.joker.APNsHelper.tester"
    static let storageKey = "fileprovider_events"
    static let maxEvents = 30

    /// 记录一条事件（字段都是字符串，便于直接展示）。
    static func record(_ event: String, detail: String? = nil) {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }

        var events = (defaults.array(forKey: storageKey) as? [[String: String]]) ?? []
        var entry = [
            "at": Self.formatter.string(from: Date()),
            "event": event
        ]
        if let detail, !detail.isEmpty {
            entry["detail"] = String(detail.prefix(400))
        }
        events.append(entry)
        if events.count > maxEvents {
            events.removeFirst(events.count - maxEvents)
        }
        defaults.set(events, forKey: storageKey)
    }

    /// 读取全部事件（按时间顺序）。
    static func events() -> [[String: String]] {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return [] }
        return (defaults.array(forKey: storageKey) as? [[String: String]]) ?? []
    }

    /// 清空事件。
    static func clear() {
        UserDefaults(suiteName: appGroup)?.removeObject(forKey: storageKey)
    }

    /// 便于展示的 JSON 文本。
    static func jsonString() -> String? {
        guard let data = try? JSONSerialization.data(
            withJSONObject: events(),
            options: [.prettyPrinted, .sortedKeys]
        ) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// ISO8601DateFormatter 非线程安全，且只在事件记录时串行使用
    private nonisolated(unsafe) static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withTime, .withTimeZone]
        return formatter
    }()
}
