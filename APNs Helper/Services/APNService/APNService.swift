//
//  APNsService.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation
import Logging
import SystemConfiguration
import NIO
import APNS
import APNSCore
import AnyCodable

struct APNsService {
    
    let config: Config
    
    var payload: AnyCodable

    let appModel: AppModel
    
    let logger: Logger

    init(config: Config, payload: AnyCodable, appModel: AppModel) {
        self.config = config
        self.payload = payload
        self.appModel = appModel
        self.logger = Logger(label: "APNs Helper") { _ in
            AppLogHandler(appModel: appModel)
        }
    }

    // swiftlint: disable function_body_length
    @discardableResult
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
                        topic: config.appBundleID,
                        payload: payload
                    ),
                    deviceToken: config.deviceToken)
            case .background:
                response = try await client?.sendBackgroundNotification(
                    .init(
                        expiration: .immediately,
                        topic: config.appBundleID,
                        payload: payload
                    ),
                    deviceToken: config.deviceToken)
            case .voip:
                response = try await client?.sendVoIPNotification(
                    .init(
                        priority: .immediately,
                        appID: config.appBundleID,
                        payload: payload
                    ),
                    deviceToken: config.pushKitVoIPToken)
            case .fileprovider:
                response = try await client?.sendFileProviderNotification(
                    .init(
                        expiration: .immediately,
                        appID: config.appBundleID,
                        payload: payload
                    ),
                    deviceToken: config.pushKitFileProviderToken)
            case .location:
                response = try await client?.sendLocationNotification(
                    .init(
                        priority: .immediately,
                        appID: config.appBundleID
                    ),
                    deviceToken: config.locationPushServiceToken)
            case .liveactivity:
                
                let mockNotification = APNSLiveActivityNotification(
                    expiration: .immediately,
                    priority: .immediately,
                    appID: config.appBundleID,
                    contentState: EmptyPayload(),
                    event: .update,
                    timestamp: 0,
                    dismissalDate: .immediately
                )
                
                response = try await client?.sendLiveActivityNotification(
                    mockNotification,
                    deviceToken: config.liveActivityPushToken)
            }
            
            if let apnsID = response?.apnsID {
                logger.notice("\(apnsID)")
            }
            
            logger.critical("Send Push Success!\napnsID: \(response?.apnsID?.uuidString ?? "None")")
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
