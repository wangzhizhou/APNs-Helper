//
//  String+Utils.swift
//  APNs Helper
//
//  Created by joker on 2023/4/6.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension String {

    static let empty = ""

    var trimmed: String { self.trimmingCharacters(in: .whitespacesAndNewlines) }

    func copyToPasteboard() {
#if os(iOS)
        UIPasteboard.general.string = self
#elseif os(macOS)
        NSPasteboard.general.declareTypes([.string], owner: nil)
        let ret = NSPasteboard.general.setString(self, forType: .string)
        assert(ret, "write string to paste board failed!")
#endif
        NotificationCenter.default.post(name: .APNSHelperStringCopyedToPastedboard, object: self)
    }

    func printDebugInfo() {
#if DEBUG
        print("[DEBUG_INFO]: \(self)")
#endif
    }
}

extension String {
    
    var floatValue: Float? {
        return Float(self)
    }
    
    var doubleValue: Double? {
        return Double(self)
    }
    
    var intValue: Int? {
        return Int(self)
    }
}

extension Notification.Name {
    static let APNSHelperStringCopyedToPastedboard = Notification.Name("APNSHelperStringCopyedToPastedboard")
}

import AnyCodable
extension String {
    var model: AnyCodable? {
        guard let data = self.data(using: .utf8)
        else {
            return nil
        }
        return try? JSONDecoder().decode(AnyCodable.self, from: data)
    }
}
