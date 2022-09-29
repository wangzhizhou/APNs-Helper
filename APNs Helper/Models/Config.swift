//
//  Config.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation

struct Config: Hashable {
    let deviceToken: String
    let pushKitDeviceToken: String
    let fileProviderDeviceToken: String
    let appBundleID: String
    let privateKey: String
    let keyIdentifier: String
    let teamIdentifier: String
    var pushType: PushType = .alert
    var apnsServerEnv: APNServerEnv = .sandbox
}
