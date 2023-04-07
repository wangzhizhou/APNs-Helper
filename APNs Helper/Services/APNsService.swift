//
//  APNsService.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation
import Logging
import NIO
import APNS
import APNSCore

enum APNServerEnv: String, CaseIterable, Codable {
    case sandbox
    case production
    
    var env: APNSEnvironment {
        switch self {
        case .sandbox:
            return .sandbox
        case .production:
            return .production
        }
    }
}

enum PushType: String, CaseIterable, Codable {
    case alert
    case background
    case voip
    
    var type: APNSPushType {
        switch self {
        case .alert:
            return .alert
        case .background:
            return .background
        case .voip:
            return .voip
        }
    }
}

struct APNsService {
    struct Payload: Codable {}
    static let logger: Logger = {
        var logger = Logger(label: "APNs Helper") { _ in
            AppLogHandler()
        }
        return logger
    }()
    
    let config: Config
    private let payload =  Payload()
    var payloadData: Data
    func send() async throws {
        
        var client: APNSClient<JSONDecoder, JSONEncoder>?
        
        do {
            guard !config.sendToSimulator else {
                // 发往模拟器
                try sendToSimulator(with: payloadData)
                return
            }
            
            client = APNSClient(
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
            
            var response: APNSResponse?
            switch config.pushType {
            case .alert:
                response = try await client?.sendAlertNotification(
                    .init(
                        alert: .init(
                            title: .raw("Simple Alert"),
                            subtitle: .raw("Subtitle"),
                            body: .raw("Body")),
                        expiration: .immediately,
                        priority: .immediately,
                        topic: config.appBundleID),
                    deviceToken: config.deviceToken)
            case .background:
                response = try await client?.sendBackgroundNotification(
                    .init(
                        expiration: .immediately,
                        topic: config.appBundleID),
                    deviceToken: config.deviceToken)
            case .voip:
                response = try await client?.sendVoIPNotification(
                    .init(
                        priority: .immediately,
                        appID: config.appBundleID),
                    deviceToken: config.pushKitDeviceToken)
            }
            
            if let apnsID = response?.apnsID {
                Self.logger.notice("\(apnsID)")
            }
        }
        catch  {
            Self.logger.error("\(error)")
        }
        
        try client?.syncShutdown()
    }
}
