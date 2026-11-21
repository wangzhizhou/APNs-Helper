//
//  Config+Utils.swift
//  APNs Helper
//
//  Created by joker on 2023/4/6.
//

import Foundation

extension Config {

    var isValid: (valid: Bool, message: String?) {

        guard !keyIdentifier.isEmpty
        else {
            return (valid: false, message: Constants.keyid.value)
        }

        guard !teamIdentifier.isEmpty
        else {
            return (valid: false, message: Constants.teamid.value)
        }

        guard !appBundleID.isEmpty
        else {
            return (valid: false, message: Constants.bundleid.value)
        }

        guard !privateKey.isEmpty
        else {
            return (valid: false, message: Constants.p8key.value)
        }

        return (valid: true, message: nil)
    }

    var isReadyForSend: (ready: Bool, message: String?) {
        var hasToken = false
        switch self.pushType {
        case .alert, .background:
            hasToken = !deviceToken.isEmpty
        case .voip:
            hasToken = !pushKitVoIPToken.isEmpty
        case .fileprovider:
            hasToken = !pushKitFileProviderToken.isEmpty
        case .location:
            hasToken = !locationPushServiceToken.isEmpty
        case .liveactivity:
            hasToken = !liveActivityPushToken.isEmpty
        }
        let (isValid, message) = isValid
        guard isValid
        else {
            return (ready: false, message: message)
        }
        guard hasToken
        else {
            return (ready: false, message: "Token")
        }
        return (ready: true, message: nil)
    }

    var isEmpty: Bool {
        self.keyIdentifier.isEmpty &&
        self.teamIdentifier.isEmpty &&
        self.appBundleID.isEmpty &&
        self.privateKey.isEmpty
    }

    static let none = Config(
        deviceToken: .empty,
        pushKitVoIPToken: .empty,
        pushKitFileProviderToken: .empty,
        locationPushServiceToken: .empty,
        liveActivityPushToken: .empty,
        appBundleID: .empty,
        privateKey: .empty,
        keyIdentifier: .empty,
        teamIdentifier: .empty)

    /// 本 App 的自测配置。凭据不入库，来自用户在本机录入的 Keychain 条目（见 `DevSecrets`），
    /// 因此这里是计算属性：录入/清除后重新读取即可生效。
    static var thisApp: Config {
        Config(
            deviceToken: .empty,
            pushKitVoIPToken: .empty,
            pushKitFileProviderToken: .empty,
            locationPushServiceToken: .empty,
            liveActivityPushToken: .empty,
            appBundleID: Bundle.main.bundleIdentifier ?? .empty,
            privateKey: DevSecrets.privateKey,
            keyIdentifier: DevSecrets.keyIdentifier,
            teamIdentifier: DevSecrets.teamIdentifier)
    }
}
