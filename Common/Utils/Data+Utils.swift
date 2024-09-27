//
//  Data+Utils.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import Foundation

extension Data {
    
    var hexString: String { reduce("") { $0 + String(format: "%02x", $1) } }
    
    var toUTF8String: String? { String(data: self, encoding: .utf8) }
}
