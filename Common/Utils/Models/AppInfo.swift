//
//  AppInfo.swift
//  APNs Helper Tester
//
//  Created by joker on 2023/5/18.
//

import Foundation

struct AppInfo: Codable {
    
    let keyID: String
    let teamID: String
    let bundleID: String
    let p8Key: String
    
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
