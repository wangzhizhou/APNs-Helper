//
//  APNsService.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation
import APNS
import APNSCore
import NIOPosix
@preconcurrency import AnyCodable

enum APNServiceError: Error {
    case notReachable
}

struct APNsService {
    
    let appInfo: AppInfo
    
    let pushType: APNPushType
    
    let apnsServerEnv: APNServerEnv
    
    let payload: AnyCodable
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func send() async throws -> UUID? {
        guard apnsServerEnv.reachable
        else {
            throw APNServiceError.notReachable
        }
        var client: APNSClient<JSONDecoder, JSONEncoder>?
        do {
            let authMethod: APNSClientConfiguration.AuthenticationMethod = .jwt(
                privateKey: try .init(pemRepresentation: appInfo.p8Key),
                keyIdentifier: appInfo.keyID,
                teamIdentifier: appInfo.teamID
            )
            let configuration: APNSClientConfiguration = .init(authenticationMethod: authMethod, environment: apnsServerEnv.env)
            client = APNSClient(
                configuration: configuration,
                eventLoopGroupProvider: .shared(MultiThreadedEventLoopGroup.singleton),
                responseDecoder: JSONDecoder(),
                requestEncoder: JSONEncoder()
            )
            let response: APNSResponse?
            switch pushType {
            case .alert:
                var alertContent = APNSAlertNotificationContent()
                if let aps = payload.jsonDict?["aps"], let alert = aps.jsonDict?["alert"] {
                    
                    if let title = alert.jsonDict?["title"]?.stringValue {
                        alertContent.title = .raw(title)
                    }
                    
                    if let subtitle = alert.jsonDict?["subtitle"]?.stringValue {
                        alertContent.subtitle = .raw(subtitle)
                    }
                    
                    if let body = alert.jsonDict?["body"]?.stringValue {
                        alertContent.body = .raw(body)
                    }
                    
                    if let launchImage = alert.jsonDict?["launch-image"]?.stringValue {
                        alertContent.launchImage = launchImage
                    }
                }
                response = try await client?.sendAlertNotification(
                    .init(
                        alert: alertContent,
                        expiration: .immediately,
                        priority: .immediately,
                        topic: appInfo.bundleID,
                        payload: payload
                    ), deviceToken: appInfo.deviceToken)
            case .background:
                response = try await client?.sendBackgroundNotification(
                    .init(expiration: .immediately, topic: appInfo.bundleID, payload: payload),
                    deviceToken: appInfo.deviceToken)
            case .voip:
                response = try await client?.sendVoIPNotification(
                    .init(priority: .immediately, appID: appInfo.bundleID, payload: payload),
                    deviceToken: appInfo.voipToken)
            case .fileprovider:
                response = try await client?.sendFileProviderNotification(
                    .init(expiration: .immediately, appID: appInfo.bundleID, payload: payload),
                    deviceToken: appInfo.fileProviderToken)
            case .location:
                response = try await client?.sendLocationNotification(
                    .init(priority: .immediately, appID: appInfo.bundleID),
                    deviceToken: appInfo.locationPushToken)
            case .liveactivity:
                if let aps = payload.jsonDict?["aps"], let contentStateAnyCodableModel = aps.jsonDict?["content-state"] {
                    var liveactivityNotification = APNSLiveActivityNotification(
                        expiration: .immediately,
                        priority: .immediately,
                        appID: appInfo.bundleID,
                        contentState: contentStateAnyCodableModel,
                        event: .update,
                        timestamp: 0,
                        dismissalDate: .immediately
                    )
                    if let event = aps.jsonDict?["event"] {
                        if event == "update" {
                            liveactivityNotification.event = .update
                        } else if event == "end" {
                            liveactivityNotification.event = .end
                        }
                    }
                    if let timestamp = aps.jsonDict?["timestamp"]?.intValue {
                        liveactivityNotification.timestamp = timestamp
                    }
                    if let dismissalDate = aps.jsonDict?["dismissal-date"]?.intValue {
                        liveactivityNotification.dismissalDate = .timeIntervalSince1970InSeconds(dismissalDate)
                    }
                    response = try await client?.sendLiveActivityNotification(liveactivityNotification, deviceToken: appInfo.liveActivityPushToken)
                } else {
                    let liveactivityNotification = APNSLiveActivityNotification(
                        expiration: .immediately,
                        priority: .immediately,
                        appID: appInfo.bundleID,
                        contentState: EmptyPayload(),
                        event: .update,
                        timestamp: 0,
                        dismissalDate: .immediately
                    )
                    response = try await client?.sendLiveActivityNotification(liveactivityNotification, deviceToken: appInfo.liveActivityPushToken)
                }
            }
            try await client?.shutdown()
            return response?.apnsID
        } catch let error {
            try await client?.shutdown()
            throw error
        }
    }
}

extension AnyCodable {
    var jsonData: Data? { try? JSONEncoder().encode(self) }
    var jsonDict: [String: AnyCodable]? {
        guard let jsonData = self.jsonData
        else {
            return nil
        }
        return try? JSONDecoder().decode([String: AnyCodable].self, from: jsonData)
    }
    var stringValue: String? {
        guard let jsonData = self.jsonData
        else {
            return nil
        }
        return try? JSONDecoder().decode(String.self, from: jsonData)
    }
    
    var intValue: Int? {
        guard let jsonData = self.jsonData
        else {
            return nil
        }
        return try? JSONDecoder().decode(Int.self, from: jsonData)
    }
}
