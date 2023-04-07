//
//  Config.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation

struct Config {
    
    // Token Info
    var deviceToken: String
    var pushKitDeviceToken: String
    var fileProviderDeviceToken: String
    
    // App Info
    var appBundleID: String
    var privateKey: String
    var keyIdentifier: String
    var teamIdentifier: String
    
    // Server Info
    var pushType: PushType = .alert
    var apnsServerEnv: APNServerEnv = .sandbox
    
    // Utils
    var sendToSimulator: Bool = false
}

extension Config: Identifiable {
    
    var id: String {
        appBundleID
    }
}

extension Config: Codable {}

extension Config: Hashable {}
