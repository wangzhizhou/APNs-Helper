//
//  URL+Utils.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import Foundation

extension URL {
    var p8FileContent: String? {
        guard self.startAccessingSecurityScopedResource() else {
            return nil
        }
        defer {
            self.stopAccessingSecurityScopedResource()
        }
        guard let data = try? Data(contentsOf: self)
        else {
            return nil
        }
        return data.toUTF8String
    }
}
