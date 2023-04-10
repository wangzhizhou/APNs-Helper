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
//    case fileprovider
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
                requestEncoder: JSONEncoder(),
                byteBufferAllocator: .init(),
                backgroundActivityLogger: Self.logger
            )

            var byteBuffer = ByteBufferAllocator().buffer(capacity: 0)
            byteBuffer.writeData(payloadData)
            _ = try JSONSerialization.jsonObject(with: byteBuffer, options: .mutableContainers)
            var token = config.deviceToken
            var topic = config.appBundleID
            var priority = 10
            switch config.pushType {
            case .alert:
                fallthrough
            case .background:
                token = config.deviceToken
                priority = 5
            case .voip:
                token = config.pushKitDeviceToken
                topic += ".voip"
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

            Self.logger.critical("Send Push Success!\napnsID: \(response.apnsID?.uuidString ?? "None")")
            await shutdownClient(client)
        }
        catch {
            Self.logger.error("Send Push Failed!", metadata: ["error": "\(error)"])
            await shutdownClient(client)
        }
    }
    
    func shutdownClient(_ client: APNSClient<JSONDecoder, JSONEncoder>?) async {
        _ = await MainActor.run {
            APNsHelperApp.model.isSendingPush = false
        }
        client?.shutdown(callback: { error in
            print("shutdown client: \(error?.localizedDescription ?? "Success")")
        })
    }
}
