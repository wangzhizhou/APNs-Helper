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
            switch config.pushType {
            case .alert:
                fallthrough
            case .background:
                token = config.deviceToken
            case .voip:
                token = config.pushKitDeviceToken
                topic += ".voip"
//            case .fileprovider:
//                token = config.fileProviderDeviceToken
                
            }
            try await client?.send(
                payload: byteBuffer,
                deviceToken: token,
                pushType: config.pushType.rawValue,
                apnsID: UUID(),
                expiration: 0,
                priority: 10,
                topic: topic,
                deadline: .distantFuture)
        }
        catch {
            Self.logger.error("Failed sending push", metadata: ["error": "\(error)"])
        }
        
        try client?.syncShutdown()
    }
}
