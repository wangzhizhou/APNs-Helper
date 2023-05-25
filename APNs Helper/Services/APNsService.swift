//
//  APNsService.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation
import APNSwift
import Logging
import SystemConfiguration
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

    var reachable: Bool {
        var reachable = false

        var hostname: String?
        switch self {
        case .sandbox:
            hostname = "api.development.push.apple.com"
        case .production:
            hostname = "api.push.apple.com"
        }
        if let hostname = hostname {
            do {
                let reachability = try Reachability(hostname: hostname)
                reachable = reachability.connection != .unavailable
            } catch {
                reachable = false
            }
        }

        return reachable
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

    let config: Config
    private let payload =  Payload()
    var payloadData: Data

    let appModel: AppModel

    let logger: Logger

    init(config: Config, payloadData: Data, appModel: AppModel) {
        self.config = config
        self.payloadData = payloadData
        self.appModel = appModel
        self.logger = Logger(label: "APNs Helper") { _ in AppLogHandler(appModel: appModel) }
    }

    // swiftlint: disable function_body_length
    func send() async throws -> Bool {

        guard config.apnsServerEnv.reachable
        else {
            appModel.toastModel = ToastModel.info().title("APN Server Not Reachable")
            return false
        }

        var client: APNSClient<JSONDecoder, JSONEncoder>?

        do {
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
                requestEncoder: JSONEncoder(),
                byteBufferAllocator: .init(),
                backgroundActivityLogger: logger
            )

            var byteBuffer = ByteBufferAllocator().buffer(capacity: 0)
            byteBuffer.writeData(payloadData)
            _ = try JSONSerialization.jsonObject(with: byteBuffer, options: .mutableContainers)
            var token = config.deviceToken
            var topic = config.appBundleID
            var priority = 10
            switch config.pushType {
            case .alert, .background:
                token = config.deviceToken
                priority = 5
            case .voip:
                token = config.pushKitVoIPToken
                topic += ".voip"
            case .fileprovider:
                priority = 5
                topic += ".pushkit.fileprovider"
                token = config.pushKitFileProviderToken
            }
            let response = try await client!.send(
                payload: byteBuffer,
                deviceToken: token,
                pushType: config.pushType.rawValue,
                apnsID: UUID(),
                expiration: 0,
                priority: priority,
                topic: topic,
                deadline: .now() + .seconds(10))

            logger.critical("Send Push Success!\napnsID: \(response.apnsID?.uuidString ?? "None")")
            await shutdownClient(client, appModel: appModel)
            return true
        } catch {
            logger.error("Send Push Failed!", metadata: ["error": "\(error)"])
            await shutdownClient(client, appModel: appModel)
            return false
        }
    }
    // swiftlint: enable function_body_length

    func shutdownClient(_ client: APNSClient<JSONDecoder, JSONEncoder>?, appModel: AppModel) async {
        _ = await MainActor.run {
            appModel.isSendingPush = false
        }
        client?.shutdown(callback: { error in
            "shutdown client: \(error?.localizedDescription ?? "Success")".printDebugInfo()
        })
    }
}
