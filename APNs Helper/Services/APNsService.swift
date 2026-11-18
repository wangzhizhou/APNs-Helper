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
        defer { appModel.isSendingPush = false }

        guard config.apnsServerEnv.reachable
        else {
            appModel.toastModel = ToastModel.info().title("APN Server Not Reachable")
            return false
        }

        do {
            // 逐字节透传用户的 JSON；非法 JSON 会在这里抛错
            let request = try PushRequest.make(config: config, payloadData: payloadData)
            logRequest(request)

            let client = try APNSClientPool.shared.client(for: config)
            let response = try await client.send(request)

            logger.critical("Send Push Success!\napnsID: \(response.apnsID?.uuidString ?? "None")")
            return true
        } catch {
            logger.error("Send Push Failed!", metadata: ["error": "\(message(for: error))"])
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

        guard let body = String(data: payloadData, encoding: .utf8)
        else { return }
        logger.notice("Payload:\n\(body)")
    }

    private func message(for error: Error) -> String {
        if let payloadError = error as? APNsPayloadError {
            return payloadError.localizedDescription
        }
        return "\(error)"
    }
}
