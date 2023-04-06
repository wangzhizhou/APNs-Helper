//
//  String+Utils.swift
//  APNs Helper
//
//  Created by joker on 2023/4/6.
//

import Foundation

extension String {
    var trimmed: String { self.trimmingCharacters(in: .whitespacesAndNewlines) }
}
