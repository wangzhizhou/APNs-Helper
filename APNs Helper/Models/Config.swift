//
//  Config.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation

struct Config: Hashable, Identifiable, Codable {
    
    // Identifiable
    var id: String {
        appBundleID
    }
    
    // App Info
    var deviceToken: String
    var pushKitDeviceToken: String
    var fileProviderDeviceToken: String
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
