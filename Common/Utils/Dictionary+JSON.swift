//
//  Dictionary+JSON.swift
//  APNs Helper
//
//  Created by joker on 2023/11/6.
//

import Foundation

extension Dictionary where Key == String {
    
    var jsonString: String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
}
