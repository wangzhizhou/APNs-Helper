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
    
    let config: Config
    
    let payload: AnyCodable
    
    // swiftlint: disable function_body_length
    func send() async throws -> APNSResponse {
        
        guard config.apnsServerEnv.reachable
        else {
            throw APNServiceError.notReachable
        }
        
        let client = APNSClient(
            configuration: .init(
                authenticationMethod: .jwt(
                    privateKey: try .init(pemRepresentation: config.privateKey),
                    keyIdentifier: config.keyIdentifier,
                    teamIdentifier: config.teamIdentifier
                ),
                environment: config.apnsServerEnv.env
            ),
            eventLoopGroupProvider: .createNew,
            responseDecoder: JSONDecoder(),
            requestEncoder: JSONEncoder()
        )
        
        var response: APNSResponse
        
        switch config.pushType {
        case .alert:
            response = try await client.sendAlertNotification(
                .init(
                    alert: .init(
                        title: .raw("Simple Alert"),
                        subtitle: .raw("Subtitle"),
                        body: .raw("Body")),
                    expiration: .immediately,
                    priority: .immediately,
                    topic: config.appBundleID,
                    payload: payload
                ),
                deviceToken: config.deviceToken)
        case .background:
            response = try await client.sendBackgroundNotification(
                .init(
                    expiration: .immediately,
                    topic: config.appBundleID,
                    payload: payload
                ),
                deviceToken: config.deviceToken)
        case .voip:
            response = try await client.sendVoIPNotification(
                .init(
                    priority: .immediately,
                    appID: config.appBundleID,
                    payload: payload
                ),
                deviceToken: config.pushKitVoIPToken)
        case .fileprovider:
            response = try await client.sendFileProviderNotification(
                .init(
                    expiration: .immediately,
                    appID: config.appBundleID,
                    payload: payload
                ),
                deviceToken: config.pushKitFileProviderToken)
        case .location:
            response = try await client.sendLocationNotification(
                .init(
                    priority: .immediately,
                    appID: config.appBundleID
                ),
                deviceToken: config.locationPushServiceToken)
        case .liveactivity:
            
            let mockNotification = APNSLiveActivityNotification(
                expiration: .immediately,
                priority: .immediately,
                appID: config.appBundleID,
                contentState: EmptyPayload(),
                event: .update,
                timestamp: 0,
                dismissalDate: .immediately
            )
            
            response = try await client.sendLiveActivityNotification(
                mockNotification,
                deviceToken: config.liveActivityPushToken)
        }
        try await shutdownClient(client)
        return response
    }
    // swiftlint: enable function_body_length
    private func shutdownClient(_ client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            client.shutdown(callback: { error in
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
