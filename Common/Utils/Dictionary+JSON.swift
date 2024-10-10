//
//  Dictionary+JSON.swift
//  APNs Helper
//
//  Created by joker on 2023/11/6.
//

import Foundation
import AnyCodable

extension Dictionary where Key == String, Value == AnyCodable {
    var jsonString: String? { try? JSONEncoder().encode(self).toUTF8String }
}
