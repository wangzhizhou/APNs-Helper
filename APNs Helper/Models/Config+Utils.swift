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
    
    var isEmpty: Bool {
        return keyIdentifier.isEmpty && teamIdentifier.isEmpty && appBundleID.isEmpty && privateKey.isEmpty
    }
    
    var isReadyForSend: Bool {
        var hasToken = false
        switch self.pushType {
        case .alert, .background:
            hasToken = !deviceToken.isEmpty
        case .voip:
            hasToken = !pushKitDeviceToken.isEmpty
        }
        return !self.isEmpty && hasToken
    }
    
    static let none = Config(
        deviceToken: .empty,
        pushKitDeviceToken: .empty,
        fileProviderDeviceToken: .empty,
        appBundleID: .empty,
        privateKey: .empty,
        keyIdentifier: .empty,
        teamIdentifier: .empty)
}
