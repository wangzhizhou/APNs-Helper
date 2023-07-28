//
//  APNsService+Template.swift
//  APNs Helper
//
//  Created by joker on 2022/9/30.
//

import Foundation
import APNS
import APNSCore

@available(macOS 11.0, *)
extension APNsService {
    
    static func templatePayload(for config: Config) -> String? {
        
        var payload: Encodable
        
        switch config.pushType {
        case .alert:
            payload = APNSAlertNotification(
                alert: .init(
                    title: .raw("Simple Alert"),
                    subtitle: .raw("Subtitle"),
                    body: .raw("Body")
                ),
                expiration: .immediately,
                priority: .immediately,
                topic: config.appBundleID
            )
        case .background:
            payload = APNSBackgroundNotification(
                expiration: .immediately,
                topic: config.appBundleID
            )
        case .voip:
            payload =  APNSVoIPNotification(
                priority: .immediately,
                appID: config.appBundleID
            )
            .payload
        case .fileprovider:
            payload = APNSFileProviderNotification(
                expiration: .immediately,
                appID: config.appBundleID
            )
            .payload
        }
        
        return payload.jsonString
    }
}

extension Encodable {
    var jsonString: String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        if let data = try? jsonEncoder.encode(self) {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }
}
