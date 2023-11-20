//
//  Array+Utils.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import Foundation

extension Array where Element: Encodable {
    var data: Data? { try? JSONEncoder().encode(self) }
}
