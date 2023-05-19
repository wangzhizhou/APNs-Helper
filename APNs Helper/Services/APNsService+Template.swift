//
//  APNsService+Template.swift
//  APNs Helper
//
//  Created by joker on 2022/9/30.
//

import Foundation
import APNSwift

@available(macOS 11.0, *)
extension APNsService {
    
    static func templatePayload(for config: Config) -> String? {
        
        var jsonString: String?
        
        switch config.pushType {
        case .alert:
            jsonString = toJSONString(with: APNSAlertNotification(
                alert: .init(
                    title: .raw("Simple Alert"),
                    subtitle: .raw("Subtitle"),
                    body: .raw("Body"),
                    launchImage: nil
                ),
                expiration: .immediately,
                priority: .immediately,
                topic: config.appBundleID,
                payload: Payload()
            ))
        case .background:
            jsonString = toJSONString(with: APNSBackgroundNotification(
                expiration: .immediately,
                topic: config.appBundleID,
                payload: Payload()
            ))
        case .voip:
            jsonString = toJSONString(with: Payload())
        case .fileprovider:
            jsonString = toJSONString(with: FileProviderPushPayload(domain: "test domain"))
        }
        return jsonString
    }
    
    static func toJSONString<T: Encodable>(with template: T) -> String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        if let data = try? jsonEncoder.encode(template) {
            return String(data: data, encoding:.utf8)
        }
        else {
            return nil
        }
    }
}
