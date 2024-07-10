//
//  Config+Payload.swift
//  APNs Helper
//
//  Created by wangzhizhou on 2024/7/10.
//

import Foundation
import APNSCore

extension Config {
    
    var jsonPayload: String? {
        
        var payload: Encodable
        
        switch self.pushType {
        case .alert:
            payload = APNSAlertNotification(
                alert: .init(
                    title: .raw("Simple Alert"),
                    subtitle: .raw("Subtitle"),
                    body: .raw("Body")
                ),
                expiration: .immediately,
                priority: .immediately,
                topic: self.appBundleID
            )
        case .background:
            payload = APNSBackgroundNotification(
                expiration: .immediately,
                topic: self.appBundleID
            )
        case .voip:
            payload = APNSVoIPNotification(
                priority: .immediately,
                appID: self.appBundleID
            )
            .payload
        case .fileprovider:
            payload = APNSFileProviderNotification(
                expiration: .immediately,
                appID: self.appBundleID
            )
            .payload
        case .location:
            payload = APNSLocationNotification(
                priority: .immediately,
                appID: self.appBundleID
            )
        case .liveactivity:
            payload = APNSLiveActivityNotification(
                expiration: .immediately,
                priority: .immediately,
                appID: self.appBundleID,
                contentState: EmptyPayload(),
                event: .update,
                timestamp: Int(Date.now.timeIntervalSince1970),
                dismissalDate: .date(.init(timeIntervalSinceNow: 30))
            )
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
        guard let data = try? jsonEncoder.encode(self)
        else {
            return nil
        }
        return data.toUTF8String
    }
}
