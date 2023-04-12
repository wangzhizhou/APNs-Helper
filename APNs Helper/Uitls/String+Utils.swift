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
    var trimmed: String { self.trimmingCharacters(in: .whitespacesAndNewlines) }
    
    func copyToPasteboard() {
#if os(iOS)
        UIPasteboard.general.string = self
#elseif os(macOS)
        NSPasteboard.general.setString(self, forType: .string)
#endif
        APNsHelperApp.model.toastMessage = "Copyed to Pasteboard!"
    }
}
