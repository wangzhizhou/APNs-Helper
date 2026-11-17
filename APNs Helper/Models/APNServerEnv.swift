//
//  APNServerEnv.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import Foundation

/// APNs 服务端环境。
///
/// 只保留领域信息（rawValue 与 host），到 `APNSEnvironment` 的映射在
/// `PushType+APNS.swift` 里，这样单元测试无需链接底层依赖。
enum APNServerEnv: String, CaseIterable, Codable {
    case sandbox
    case production

    /// 该环境对应的 APNs 主机名，用于可达性检测。
    var hostname: String {
        switch self {
        case .sandbox:
            return "api.development.push.apple.com"
        case .production:
            return "api.push.apple.com"
        }
    }
}
