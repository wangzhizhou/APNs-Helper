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

    /// 发送超时：避免网络黑洞时界面一直停在「Sending...」而无法继续操作（issue #9）
    static let sendTimeout: Duration = .seconds(30)

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
            let apnsID = try await sendWithTimeout(request, client: client)

            logger.critical("Send Push Success!\napnsID: \(apnsID?.uuidString ?? "None")")
            return true
        } catch {
            // 复用的连接可能已经失效（网络切换、token 过期等）：
            // 丢弃它，保证下一次发送是全新的连接与 JWT，而不是一直失败
            APNSClientPool.shared.invalidate()
            logger.error("Send Push Failed!", metadata: ["error": "\(message(for: error))"])
            return false
        }
    }

    @MainActor
    private func sendWithTimeout(
        _ request: APNSRequest<RawPayloadNotification>,
        client: APNSClient<JSONDecoder, RawBodyEncoder>
    ) async throws -> UUID? {
        let sendTask = Task { try await client.send(request).apnsID }
        let timeoutTask = Task {
            try? await Task.sleep(for: Self.sendTimeout)
            sendTask.cancel()
        }
        defer { timeoutTask.cancel() }

        do {
            return try await sendTask.value
        } catch is CancellationError {
            throw APNsSendError.timedOut(Self.sendTimeout)
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

enum APNsSendError: LocalizedError {
    case timedOut(Duration)

    var errorDescription: String? {
        switch self {
        case .timedOut(let duration):
            return "Send Push Timeout after \(duration)"
        }
    }
}
