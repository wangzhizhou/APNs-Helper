//
//  Data+Hex.swift
//  APNs Helper
//
//  Created by joker on 2023/4/12.
//

import Foundation

extension Data {
    var hexString: String { reduce("") { $0 + String(format: "%02x", $1) } }
}
