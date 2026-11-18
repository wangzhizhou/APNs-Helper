//
//  APNsService.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation
import Logging
import APNS
import APNSCore

extension APNServerEnv {

    /// 该环境是否可达（用于发送前的前置检查）。
    var reachable: Bool {
        do {
            let reachability = try Reachability(hostname: hostname)
            return reachability.connection != .unavailable
        } catch {
            return false
        }
    }
}

struct APNsService {
    
    let config: Config
    
    var payloadData: Data

    let appModel: AppModel
    
    let logger: Logger

    init(config: Config, payloadData: Data, appModel: AppModel) {
        self.config = config
        self.payloadData = payloadData
        self.appModel = appModel
        self.logger = Logger(label: "APNs Helper") { _ in
            AppLogHandler(appModel: appModel)
        }
    }

    @MainActor
    func send() async throws -> Bool {

        guard config.apnsServerEnv.reachable
        else {
            appModel.toastModel = ToastModel.info().title("APN Server Not Reachable")
            return false
        }

        guard let payload = JSONValue(jsonData: payloadData)
        else {
            logger.error("Invalid Payload, please check the JSON format")
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
                requestEncoder: JSONEncoder()
            )

            let request = PushRequest.make(config: config, payload: payload)
            logRequest(request)
            let response: APNSResponse? = try await client?.send(request)

            if let apnsID = response?.apnsID {
                logger.notice("\(apnsID)")
            }
            
            logger.critical("Send Push Success!\napnsID: \(response?.apnsID?.uuidString ?? "None")")
            await shutdownClient(client)
            return true
        } catch {
            logger.error("Send Push Failed!", metadata: ["error": "\(error)"])
            await shutdownClient(client)
            return false
        }
    }

    /// 把实际发出的头信息与 Body 记到界面日志，便于和接收到的 Payload 对照。
    @MainActor
    func logRequest(_ request: APNSRequest<RawPayloadNotification>) {
        let headers = request.headers
        let summary = ["apns-topic", "apns-push-type", "apns-priority", "apns-expiration"]
            .compactMap { key in headers[key].map { "\(key)=\($0)" } }
            .joined(separator: " ")
        logger.notice("APNs request: \(summary)")
        if let body = String(data: payloadData, encoding: .utf8) {
            logger.notice("Payload:\n\(body)")
        }
    }

    @MainActor
    func shutdownClient(_ client: APNSClient<JSONDecoder, JSONEncoder>?) async {
        appModel.isSendingPush = false
        do {
            try await client?.shutdown()
        } catch {
            "shutdown client: \(error.localizedDescription)".printDebugInfo()
        }
    }
}
