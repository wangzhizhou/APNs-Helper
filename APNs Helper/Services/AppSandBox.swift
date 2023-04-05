//
//  AppSandBox.swift
//  APNs Helper
//
//  Created by joker on 2022/10/3.
//

import Foundation

struct AppSandbox {
    static func isSandbox() -> Bool {
#if os(macOS)
        return NSHomeDirectory().contains("Containers")
//#elseif os(iOS)
//        return true
#else
        return false
#endif
    }
}
