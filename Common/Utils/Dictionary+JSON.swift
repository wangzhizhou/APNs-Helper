//
//  Dictionary+JSON.swift
//  APNs Helper
//
//  Created by joker on 2023/11/6.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    
    var jsonString: String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
}

extension Dictionary where Key == AnyHashable, Value == Any {

    /// 通知 `userInfo` 这类 `[AnyHashable: Any]` 的 JSON 表示（用于日志/诊断）。
    var jsonString: String? {
        let converted: [String: Any] = reduce(into: [:]) { result, element in
            result["\(element.key)"] = element.value
        }
        return converted.jsonString
    }
}
