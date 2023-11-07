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
    var deviceToken: String = ""
    var voipToken: String = ""
    var fileProviderToken: String = ""
    var locationPushToken: String = ""
    var liveActivityPushToken: String = ""
}

extension AppInfo {

    var jsonString: String? {
        if let data = try? Self.jsonEncoder.encode(self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    var formattedText: String? {
        
        guard
            let data = try? Self.jsonEncoder.encode(self),
            let jsonObj = try? Self.jsonDecoder.decode([String: String].self, from: data)
        else {
            return nil
        }
        
        
        let ret = jsonObj
            .enumerated()
            .map { "\($0.element.key)\n\($0.element.value)" }.sorted()
            .reduce("") { partialResult, entry in
                "\(partialResult)\(entry)\n\n"
            }.trimmed
        
        return ret
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
        if let data = json.data(using: .utf8), let appInfo = try? Self.jsonDecoder.decode(AppInfo.self, from: data) {
            return appInfo
        }
        return nil
    }
}
