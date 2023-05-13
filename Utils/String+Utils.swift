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
        NSPasteboard.general.setString(self, forType: .string)
#endif
        NotificationCenter.default.post(name: .APNSHelperStringCopyedToPastedboard, object: self)
    }
    
    func printDebugInfo() {
#if DEBUG
        print("[DEBUG_INFO]: \(self)")
#endif
    }
}

extension Notification.Name {
    static let APNSHelperStringCopyedToPastedboard = Notification.Name("APNSHelperStringCopyedToPastedboard")
}
