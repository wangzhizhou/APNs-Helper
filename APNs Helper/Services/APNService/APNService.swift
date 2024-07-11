//
//  APNsService.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation
import APNS
import APNSCore
import AnyCodable

enum APNServiceError: Error {
    case notReachable
}

struct APNsService {
    
    let appInfo: AppInfo
    
    let pushType: APNPushType
    
    let apnsServerEnv: APNServerEnv
    
    let payload: AnyCodable
    
    // swiftlint: disable function_body_length
    func send() async throws -> APNSResponse? {
        
        guard apnsServerEnv.reachable
        else {
            throw APNServiceError.notReachable
        }
        
        var client: APNSClient<JSONDecoder, JSONEncoder>?

        do {
            client = APNSClient(
                configuration: .init(
                    authenticationMethod: .jwt(
                        privateKey: try .init(pemRepresentation: appInfo.p8Key),
                        keyIdentifier: appInfo.keyID,
                        teamIdentifier: appInfo.teamID
                    ),
                    environment: apnsServerEnv.env
                ),
                eventLoopGroupProvider: .createNew,
                responseDecoder: JSONDecoder(),
                requestEncoder: JSONEncoder()
            )
            
            var response: APNSResponse?
            
            switch pushType {
            case .alert:
                response = try await client?.sendAlertNotification(
                    .init(
                        alert: .init(
                            title: .raw("Simple Alert"),
                            subtitle: .raw("Subtitle"),
                            body: .raw("Body")),
                        expiration: .immediately,
                        priority: .immediately,
                        topic: appInfo.bundleID,
                        payload: payload
                    ),
                    deviceToken: appInfo.deviceToken)
            case .background:
                response = try await client?.sendBackgroundNotification(
                    .init(
                        expiration: .immediately,
                        topic: appInfo.bundleID,
                        payload: payload
                    ),
                    deviceToken: appInfo.deviceToken)
            case .voip:
                response = try await client?.sendVoIPNotification(
                    .init(
                        priority: .immediately,
                        appID: appInfo.bundleID,
                        payload: payload
                    ),
                    deviceToken: appInfo.voipToken)
            case .fileprovider:
                response = try await client?.sendFileProviderNotification(
                    .init(
                        expiration: .immediately,
                        appID: appInfo.bundleID,
                        payload: payload
                    ),
                    deviceToken: appInfo.fileProviderToken)
            case .location:
                response = try await client?.sendLocationNotification(
                    .init(
                        priority: .immediately,
                        appID: appInfo.bundleID
                    ),
                    deviceToken: appInfo.locationPushToken)
            case .liveactivity:
                
                let mockNotification = APNSLiveActivityNotification(
                    expiration: .immediately,
                    priority: .immediately,
                    appID: appInfo.bundleID,
                    contentState: EmptyPayload(),
                    event: .update,
                    timestamp: 0,
                    dismissalDate: .immediately
                )
                
                response = try await client?.sendLiveActivityNotification(
                    mockNotification,
                    deviceToken: appInfo.liveActivityPushToken)
            }
            try await shutdownClient(client)
            return response
        } catch let error {
            try await shutdownClient(client)
            throw error
        }
    }
    // swiftlint: enable function_body_length
    private func shutdownClient(_ client: APNSClient<JSONDecoder, JSONEncoder>?) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            client?.shutdown(callback: { error in
                guard let error
                else {
                    continuation.resume()
                    return
                }
                continuation.resume(throwing: error)
            })
        }
    }
}
