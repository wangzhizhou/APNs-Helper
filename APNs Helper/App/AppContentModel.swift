//
//  ContentModel.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI

@Observable
final class AppContentModel {
    
    var selectedAppInfo: AppInfo = .none
    
    var appInfo: AppInfo = .none
    
    var pushType: APNPushType = .alert
    
    var apnsServerEnv: APNServerEnv = .development
    
    var payload: String = ""
    
    var showFileImporter: Bool = false
    
    var isInTestMode: Bool = false
}

extension AppContentModel {
    
    var config: AppInfo { appInfo.trimmed }
    
    func clearAppInfo() { appInfo = .none }
    
    var isReadyForSend: (ready: Bool, message: String?) {
        var hasToken = false
        switch self.pushType {
        case .alert, .background:
            hasToken = !appInfo.deviceToken.isEmpty
        case .voip:
            hasToken = !appInfo.voipToken.isEmpty
        case .fileprovider:
            hasToken = !appInfo.fileProviderToken.isEmpty
        case .location:
            hasToken = !appInfo.locationPushToken.isEmpty
        case .liveactivity:
            hasToken = !appInfo.liveActivityPushToken.isEmpty
        }
        let (isValid, message) = appInfo.isValid
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
    
}

import APNSCore
extension AppContentModel {
    
    var jsonTemplatePayload: String? {
        
        var payload: Encodable
        
        let topic = appInfo.bundleID
        
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
                topic: topic
            )
        case .background:
            payload = APNSBackgroundNotification(
                expiration: .immediately,
                topic: topic
            )
        case .voip:
            payload = APNSVoIPNotification(
                priority: .immediately,
                appID: topic
            )
            .payload
        case .fileprovider:
            payload = APNSFileProviderNotification(
                expiration: .immediately,
                appID: topic
            )
            .payload
        case .location:
            payload = APNSLocationNotification(
                priority: .immediately,
                appID: topic
            )
        case .liveactivity:
            payload = APNSLiveActivityNotification(
                expiration: .immediately,
                priority: .immediately,
                appID: topic,
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
