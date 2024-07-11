//
//  Config.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation
import SwiftData

@Model
final class Config {

    // Token Info
    var deviceToken: String
    var pushKitVoIPToken: String
    var pushKitFileProviderToken: String
    var locationPushServiceToken: String
    var liveActivityPushToken: String

    // App Info
    @Attribute(.unique)
    var appBundleID: String
    
    var privateKey: String
    var keyIdentifier: String
    var teamIdentifier: String

    // Server Info
    
    @Transient
    var pushType: APNPushType = .alert
    
    @Transient
    var apnsServerEnv: APNServerEnv = .development
    
    init(
        deviceToken: String,
        pushKitVoIPToken: String,
        pushKitFileProviderToken: String,
        locationPushServiceToken: String,
        liveActivityPushToken: String,
        appBundleID: String,
        privateKey: String,
        keyIdentifier: String,
        teamIdentifier: String,
        pushType: APNPushType  = .alert,
        apnsServerEnv: APNServerEnv = .development) {
            self.deviceToken = deviceToken
            self.pushKitVoIPToken = pushKitVoIPToken
            self.pushKitFileProviderToken = pushKitFileProviderToken
            self.locationPushServiceToken = locationPushServiceToken
            self.liveActivityPushToken = liveActivityPushToken
            self.appBundleID = appBundleID
            self.privateKey = privateKey
            self.keyIdentifier = keyIdentifier
            self.teamIdentifier = teamIdentifier
            self.pushType = pushType
            self.apnsServerEnv = apnsServerEnv
        }
}

extension Config: Equatable {
    
    static func == (lhs: Config, rhs: Config) -> Bool {
        return lhs.deviceToken == rhs.deviceToken
        && lhs.pushKitVoIPToken == rhs.pushKitVoIPToken
        && lhs.pushKitFileProviderToken == rhs.pushKitFileProviderToken
        && lhs.appBundleID == rhs.appBundleID
        && lhs.privateKey == rhs.privateKey
        && lhs.keyIdentifier == rhs.keyIdentifier
        && lhs.teamIdentifier == rhs.teamIdentifier
        && lhs.pushType == rhs.pushType
        && lhs.apnsServerEnv == rhs.apnsServerEnv
    }
}

extension Config: Comparable {
    static func < (lhs: Config, rhs: Config) -> Bool {
        return lhs.appBundleID < rhs.appBundleID
    }
}

extension Config {
    var trimmed: Config {
        .init(
            deviceToken: deviceToken.trimmed,
            pushKitVoIPToken: pushKitVoIPToken.trimmed,
            pushKitFileProviderToken: pushKitFileProviderToken.trimmed,
            locationPushServiceToken: locationPushServiceToken.trimmed,
            liveActivityPushToken: liveActivityPushToken.trimmed,
            appBundleID: appBundleID.trimmed,
            privateKey: privateKey,
            keyIdentifier: keyIdentifier.trimmed,
            teamIdentifier: teamIdentifier.trimmed,
            pushType: pushType,
            apnsServerEnv: apnsServerEnv
        )
    }
}
