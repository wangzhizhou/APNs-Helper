//
//  Config+Utils.swift
//  APNs Helper
//
//  Created by joker on 2023/4/6.
//

import Foundation

extension Config {
    
    var isValidForSave: (valid: Bool, message: String?) {
        
        var message = [String]()
        
        if keyIdentifier.isEmpty {
            message.append("KeyID")
        }
        if teamIdentifier.isEmpty {
            message.append("TeamID")
        }
        if appBundleID.isEmpty {
            message.append("BundleID")
        }
        if privateKey.isEmpty {
            message.append("P8Key")
        }
        
        if message.isEmpty {
            return (valid: true, message: nil)
        } else {
            return (valid: false, message: "\(message.joined(separator: "\n"))\nis Empty")
        }
    }
}
