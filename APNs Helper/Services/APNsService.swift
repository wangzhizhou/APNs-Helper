//
//  APNsService.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation
import APNSwift
import Logging
import AppKit

enum APNServerEnv: String, CaseIterable {
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

enum PushType: String, CaseIterable {
    case alert = "Alert"
    case background = "Background"
    case voip = "VoIP"
    case fileProvider = "File Provider"
}

struct APNsService {
    struct Payload: Codable {
        let json: String
    }
    static let logger: Logger = {
        var logger = Logger(label: "APNs Helper") { _ in 
            AppLogHandler()
        }
        return logger
    }()
        
    let config: Config
    let payload: Payload
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
            switch config.pushType {
            case .alert:
                try await sendSimpleAlert(with: client)
                try await sendLocalizedAlert(with: client)
                try await sendThreadedAlert(with: client)
                try await sendCustomCategoryAlert(with: client)
                try await sendMutableContentAlert(with: client)
            case .background:
                try await sendBackground(with: client)
            case .voip:
                try await sendVoIP(with: client)
            case .fileProvider:
                try await sendFileProvider(with: client)
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
            ),
            deviceToken: config.deviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }

    func sendLocalizedAlert(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendAlertNotification(
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
            ),
            deviceToken: config.deviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }

    func sendThreadedAlert(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendAlertNotification(
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
            ),
            deviceToken: config.deviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }

    func sendCustomCategoryAlert(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendAlertNotification(
            .init(
                alert: .init(
                    title: .raw("Custom Category Alert"),
                    subtitle: .raw("Subtitle"),
                    body: .raw("Body"),
                    launchImage: nil
                ),
                expiration: .immediately,
                priority: .immediately,
                topic: config.appBundleID,
                payload: payload,
                category: "CUSTOM"
            ),
            deviceToken: config.deviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }

    func sendMutableContentAlert(with client: APNSClient<JSONDecoder, JSONEncoder>) async throws {
        try await client.sendAlertNotification(
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
            ),
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
            .init(
                expiration: .immediately,
                topic: config.appBundleID,
                payload: payload
            ),
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
            .init(
                expiration: .immediately,
                priority: .immediately,
                appID: config.appBundleID,
                payload: payload
            ),
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
            .init(
                expiration: .immediately,
                appID: config.appBundleID,
                payload: payload
            ),
            deviceToken: config.fileProviderDeviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }
}
