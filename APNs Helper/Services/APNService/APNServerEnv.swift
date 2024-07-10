//
//  APNServerEnv.swift
//  APNs Helper
//
//  Created by wangzhizhou on 2024/7/10.
//

import Foundation
import APNSCore

enum APNServerEnv: String, CaseIterable, Codable {
    case development
    case production
}

extension APNServerEnv {
    
    var env: APNSEnvironment {
        switch self {
        case .development:
            return .development
        case .production:
            return .production
        }
    }
    
    var reachable: Bool {
        var reachable = false
        
        var hostname: String?
        switch self {
        case .development:
            hostname = "api.development.push.apple.com"
        case .production:
            hostname = "api.push.apple.com"
        }
        if let hostname = hostname {
            do {
                let reachability = try Reachability(hostname: hostname)
                reachable = reachability.connection != .unavailable
            } catch {
                reachable = false
            }
        }
        
        return reachable
    }
}
