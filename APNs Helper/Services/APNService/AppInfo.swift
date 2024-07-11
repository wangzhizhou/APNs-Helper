//
//  AppInfo.swift
//  APNs Helper Tester
//
//  Created by joker on 2023/5/18.
//

import Foundation

struct AppInfo: Codable, Hashable {
    
    var keyID: String
    var teamID: String
    var bundleID: String
    var p8Key: String
    
    var deviceToken: String = .empty
    var voipToken: String = .empty
    var fileProviderToken: String = .empty
    var locationPushToken: String = .empty
    var liveActivityPushToken: String = .empty
}

extension AppInfo {
    
    var jsonString: String? {
        guard let data = try? Self.jsonEncoder.encode(self)
        else {
            return nil
        }
        return data.toUTF8String
    }
    
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        return encoder
    }()
    
    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    static func decode(from json: String) -> AppInfo? {
        var ret: AppInfo?
        do {
            if let data = json.data(using: .utf8) {
                ret = try Self.jsonDecoder.decode(AppInfo.self, from: data)
            }
        } catch {
            print(error)
        }
        return ret
    }
}

extension AppInfo {
    
    var asDictionary: [String: String]? {
        
        guard
            let data = try? JSONEncoder().encode(self),
            let jsonObj = try? JSONDecoder().decode([String: String].self, from: data)
        else {
            return nil
        }
        
        return jsonObj
    }
    
    func formattedText(with orderedValues: [String]) -> String? {
        
        guard let dictionary = asDictionary
        else {
            return nil
        }
        
        var valueToKeyDict = [String: String]()
        dictionary.forEach { (key: String, value: String) in
            guard !value.isEmpty
            else {
                return
            }
            valueToKeyDict[value] = key
        }
        
        let ret = orderedValues.compactMap { value in
            guard let key = valueToKeyDict[value]
            else {
                return nil
            }
            return "\(key)\n\(value)"
        }.joined(separator: "\n\n")
        
        return ret
    }
    
    static func jsonStringFromFormattedText(_ formattedText: String?) -> String? {
        guard let formattedText = formattedText
        else {
            return nil
        }
        
        let emptyAppInfo = AppInfo(keyID: .empty, teamID: .empty, bundleID: .empty, p8Key: .empty)
        var emptyAppInfoJsonObj = emptyAppInfo.asDictionary ?? [String: String]()
        formattedText.split(separator: "\n\n").forEach { kvPair in
            let kvArr = kvPair.split(separator: "\n", maxSplits: 1).map { String($0) }
            guard let key = kvArr.first, let value = kvArr.last
            else {
                return
            }
            emptyAppInfoJsonObj[key] = value
        }
        
        let ret = emptyAppInfoJsonObj.jsonString
        return ret
    }
}


extension AppInfo {
    
    var trimmed: AppInfo {
        
        .init(
            keyID: keyID.trimmed,
            teamID: teamID.trimmed,
            bundleID: bundleID.trimmed,
            p8Key: p8Key.trimmed,
            deviceToken: deviceToken.trimmed,
            voipToken: voipToken.trimmed,
            fileProviderToken: fileProviderToken.trimmed,
            locationPushToken: locationPushToken.trimmed,
            liveActivityPushToken: liveActivityPushToken.trimmed
        )
    }
    
    static let none = AppInfo(
        keyID: .empty,
        teamID: .empty,
        bundleID: .empty,
        p8Key: .empty,
        deviceToken: .empty,
        voipToken: .empty,
        fileProviderToken: .empty,
        locationPushToken: .empty,
        liveActivityPushToken: .empty
    )
    
    static let test = AppInfo(
        keyID: "test key id",
        teamID: "test team id",
        bundleID: "test bundle id",
        p8Key: "test private key",
        deviceToken: "test device token",
        voipToken: "test pushkit voip token",
        fileProviderToken: "test file provider token",
        locationPushToken: "test location push service token",
        liveActivityPushToken: "test live activity push token"
    )
    
    static let thisAppInfo = AppInfo(
        keyID: "7S6SUT5L43",
        teamID: "2N62934Y28",
        bundleID: Bundle.main.bundleIdentifier ?? .empty,
        p8Key: """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgViPOgSdnJxJ2gXfH
        iFJM4tkQhhakxYWGek6Ozwm2wkWhRANCAATiYzEZHM2oniKXJHZK123blIlSQUTp
        n2c05lXz66Ifu6eCVNoXignIS5SmDYS29CchZHQzXrinraNSTTNKgMo+
        -----END PRIVATE KEY-----
        """,
        deviceToken: .empty,
        voipToken: .empty,
        fileProviderToken: .empty,
        locationPushToken: .empty,
        liveActivityPushToken: .empty
    )
    
    var isEmpty: Bool {
        keyID.isEmpty &&
        teamID.isEmpty &&
        bundleID.isEmpty &&
        p8Key.isEmpty &&
        deviceToken.isEmpty &&
        voipToken.isEmpty &&
        fileProviderToken.isEmpty &&
        locationPushToken.isEmpty &&
        liveActivityPushToken.isEmpty
    }
    
    var isValid: (valid: Bool, message: String?) {
        
        guard !keyID.isEmpty
        else {
            return (valid: false, message: Constants.keyid.value)
        }
        
        guard !teamID.isEmpty
        else {
            return (valid: false, message: Constants.teamid.value)
        }
        
        guard !bundleID.isEmpty
        else {
            return (valid: false, message: Constants.bundleid.value)
        }
        
        guard !p8Key.isEmpty
        else {
            return (valid: false, message: Constants.p8key.value)
        }
        
        return (valid: true, message: nil)
    }
    
    var toConfig: Config {
        Config(
            deviceToken: deviceToken,
            pushKitVoIPToken: voipToken,
            pushKitFileProviderToken: fileProviderToken,
            locationPushServiceToken: locationPushToken,
            liveActivityPushToken: liveActivityPushToken,
            appBundleID: bundleID,
            privateKey: p8Key,
            keyIdentifier: keyID,
            teamIdentifier: teamID
        )
    }
}
