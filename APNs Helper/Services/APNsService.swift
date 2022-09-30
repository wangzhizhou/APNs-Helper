//
//  APNsService.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation
import APNSwift
import Logging
import NIO

enum APNServerEnv: String, CaseIterable, Codable {
    case sandbox
    case production
    
    var env: APNSClientConfiguration.Environment {
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
    case fileprovider
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
    var payloadData: Data? = nil
    func send() async throws {
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
            requestEncoder: JSONEncoder(),
            byteBufferAllocator: .init(),
            backgroundActivityLogger: Self.logger
        )
        defer {
            client.shutdown { _ in
                Self.logger.error("Failed to shutdown APNSClient")
            }
        }
        
        do {
            if let payloadData = payloadData {
                var byteBuffer = ByteBufferAllocator().buffer(capacity: 0)
                byteBuffer.writeData(payloadData)
                _ = try JSONSerialization.jsonObject(with: byteBuffer, options: .mutableContainers)
                try await client.send(
                    payload: byteBuffer,
                    deviceToken: config.deviceToken,
                    pushType: config.pushType.rawValue,
                    apnsID: UUID(),
                    expiration: 0,
                    priority: 10,
                    topic: config.appBundleID,
                    deadline: .distantFuture)
            }
            else {
                switch config.pushType {
                case .alert:
                    try await sendSimpleAlert(with: client)
                case .background:
                    try await sendBackground(with: client)
                case .voip:
                    try await sendVoIP(with: client)
                case .fileprovider:
                    try await sendFileProvider(with: client)
                }
            }
            
        } catch {
            Self.logger.error("Failed sending push", metadata: ["error": "\(error)"])
        }
    }
}

// MARK: Alerts

@available(macOS 11.0, *)
extension APNsService {
    func sendSimpleAlert(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendAlertNotification(
            self.simpleAlertTemplate,
            deviceToken: config.deviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }
    
    func sendLocalizedAlert(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendAlertNotification(
            self.localizedAlertTemplate,
            deviceToken: config.deviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }
    
    func sendThreadedAlert(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendAlertNotification(
            self.threadAlertTemplate,
            deviceToken: config.deviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }
    
    func sendCustomCategoryAlert(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendAlertNotification(
            self.customCategoryAlertTemplate,
            deviceToken: config.deviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }
    
    func sendMutableContentAlert(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendAlertNotification(
            self.mutableContentAlertTemplate,
            deviceToken: config.deviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }
}

// MARK: Background

@available(macOS 11.0, *)
extension APNsService {
    func sendBackground(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendBackgroundNotification(
            self.backgroundTemplate,
            deviceToken: config.deviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }
}

// MARK: VoIP

@available(macOS 11.0, *)
extension APNsService {
    func sendVoIP(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendVoIPNotification(
            self.voipTemplate,
            deviceToken: config.pushKitDeviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }
}

// MARK: FileProvider

@available(macOS 11.0, *)
extension APNsService {
    func sendFileProvider(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendFileProviderNotification(
            self.fileproviderTemplate,
            deviceToken: config.fileProviderDeviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }
}

@available(macOS 11.0, *)
extension APNsService {
    var simpleAlertTemplate: APNSAlertNotification<Payload> {
        .init(
            alert: .init(
                title: .raw("Simple Alert"),
                subtitle: .raw("Subtitle"),
                body: .raw("Body"),
                launchImage: nil
            ),
            expiration: .immediately,
            priority: .immediately,
            topic: config.appBundleID,
            payload: payload
        )
    }
    
    var localizedAlertTemplate: APNSAlertNotification<Payload> {
        .init(
            alert: .init(
                title: .localized(key: "title", arguments: ["Localized"]),
                subtitle: .localized(key: "subtitle", arguments: ["APNS"]),
                body: .localized(key: "body", arguments: ["APNS"]),
                launchImage: nil
            ),
            expiration: .immediately,
            priority: .immediately,
            topic: config.appBundleID,
            payload: payload
        )
    }
    
    var threadAlertTemplate: APNSAlertNotification<Payload> {
        .init(
            alert: .init(
                title: .raw("Threaded Alert"),
                subtitle: .raw("Subtitle"),
                body: .raw("Body"),
                launchImage: nil
            ),
            expiration: .immediately,
            priority: .immediately,
            topic: config.appBundleID,
            payload: payload,
            threadID: "thread"
        )
    }
    
    var customCategoryAlertTemplate: APNSAlertNotification<Payload> {
        .init(
            alert: .init(
                title: .raw("Mutable Alert"),
                subtitle: .raw("Subtitle"),
                body: .raw("Body"),
                launchImage: nil
            ),
            expiration: .immediately,
            priority: .immediately,
            topic: config.appBundleID,
            payload: payload,
            mutableContent: 1
        )
    }
    
    var mutableContentAlertTemplate: APNSAlertNotification<Payload> {
        .init(
            alert: .init(
                title: .raw("Mutable Alert"),
                subtitle: .raw("Subtitle"),
                body: .raw("Body"),
                launchImage: nil
            ),
            expiration: .immediately,
            priority: .immediately,
            topic: config.appBundleID,
            payload: payload,
            mutableContent: 1
        )
    }
    
    var backgroundTemplate: APNSBackgroundNotification<Payload> {
        .init(
            expiration: .immediately,
            topic: config.appBundleID,
            payload: payload
        )
    }
    
    
    var voipTemplate: APNSVoIPNotification<Payload> {
        .init(
            expiration: .immediately,
            priority: .immediately,
            appID: config.appBundleID,
            payload: payload
        )
    }
    
    var fileproviderTemplate: APNSFileProviderNotification<Payload> {
        .init(
            expiration: .immediately,
            appID: config.appBundleID,
            payload: payload
        )
    }
    
    func toJSONString<T: Encodable>(with template: T) -> String? {
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
