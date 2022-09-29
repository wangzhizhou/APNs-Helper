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
    
    struct Payload: Codable {}
    static let logger: Logger = {
        var logger = Logger(label: "APNs Helper")
        logger.logLevel = .trace
        return logger
    }()
        
    let config: Config
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
                payload: Payload()
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
                payload: Payload()
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
                payload: Payload(),
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
                payload: Payload(),
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
                payload: Payload(),
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
                payload: Payload()
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
                payload: Payload()
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
                payload: Payload()
            ),
            deviceToken: config.fileProviderDeviceToken,
            deadline: .distantFuture,
            logger: Self.logger
        )
    }
}


import UniformTypeIdentifiers
@available(macOS 11.0, *)
extension APNsService {
    static func chooseP8AndDecrypt() -> (output: String?, error: String?) {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "选择"
        if let p8UTType = UTType(filenameExtension: "p8") {
            openPanel.allowedContentTypes = [p8UTType]
        }
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.runModal()
        if let p8FileURL = openPanel.url {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/openssl")
            process.arguments = [
                "pkcs8",
                "-nocrypt",
                "-in",
                "\(p8FileURL.path)"
            ]
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            try? process.run()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8)
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let error = String(data: errorData, encoding: .utf8)
            return (output: output, error: error)
        }
        return (nil, "无效文件路径")
    }
    
}
