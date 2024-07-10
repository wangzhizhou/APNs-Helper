//
//  APNPushType.swift
//  APNs Helper
//
//  Created by wangzhizhou on 2024/7/10.
//

import Foundation
import APNSCore

enum APNPushType: String, CaseIterable, Codable {
    case alert
    case background
    case voip
    case fileprovider
    case location
    case liveactivity
}

extension APNPushType {
    var type: APNSPushType {
        switch self {
        case .alert:
            return .alert
        case .background:
            return .background
        case .voip:
            return .voip
        case .fileprovider:
            return .fileprovider
        case .location:
            return .location
        case .liveactivity:
            return .liveactivity
        }
    }
}
