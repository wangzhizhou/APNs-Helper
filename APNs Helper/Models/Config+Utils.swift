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
        appBundleID: .empty,
        privateKey: .empty,
        keyIdentifier: .empty,
        teamIdentifier: .empty)

    static let thisApp = Config(
        deviceToken: .empty,
        pushKitVoIPToken: .empty,
        pushKitFileProviderToken: .empty,
        locationPushServiceToken: .empty,
        appBundleID: Bundle.main.bundleIdentifier ?? .empty,
        privateKey: """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgViPOgSdnJxJ2gXfH
        iFJM4tkQhhakxYWGek6Ozwm2wkWhRANCAATiYzEZHM2oniKXJHZK123blIlSQUTp
        n2c05lXz66Ifu6eCVNoXignIS5SmDYS29CchZHQzXrinraNSTTNKgMo+
        -----END PRIVATE KEY-----
        """,
        keyIdentifier: "7S6SUT5L43",
        teamIdentifier: "2N62934Y28")
}
