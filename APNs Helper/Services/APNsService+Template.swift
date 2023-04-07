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
        config.pushType.templateMessage(topic: config.appBundleID).jsonString
    }
}

extension APNSMessage {
    var jsonString: String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        if let data = try? jsonEncoder.encode(self) {
            return String(data: data, encoding:.utf8)
        }
        else {
            return nil
        }
    }
}

extension PushType {
    func templateMessage(topic: String) -> APNSMessage {
        switch self {
        case .alert:
            return APNSAlertNotification(
                alert: .init(
                    title: .raw("Simple Alert"),
                    subtitle: .raw("Subtitle"),
                    body: .raw("Body")
                ),
                expiration: .immediately,
                priority: .immediately,
                topic: topic
            )
        case .background:
            return APNSBackgroundNotification(
                expiration: .immediately,
                topic: topic
            )
        case .voip:
            return APNSVoIPNotification(
                priority: .immediately,
                appID: topic)
        }
    }
}
