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
    var pushKitVoIPToken: String
    var pushKitFileProviderToken: String
    var locationPushServiceToken: String
    var liveActivityPushToken: String

    // App Info
    var appBundleID: String
    var privateKey: String
    var keyIdentifier: String
    var teamIdentifier: String

    // Server Info
    var pushType: PushType = .alert
    var apnsServerEnv: APNServerEnv = .sandbox
}

extension Config: Identifiable {

    var id: String {
        appBundleID
    }
}

extension Config: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
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

extension Config: Codable {}

extension Config: Hashable {}

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
