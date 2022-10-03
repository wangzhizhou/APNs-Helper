//
//  AppSandBox.swift
//  APNs Helper
//
//  Created by joker on 2022/10/3.
//

import Foundation

struct AppSandbox {
    static func isSandbox() -> Bool {
        return NSHomeDirectory().contains("Containers")
    }
}
