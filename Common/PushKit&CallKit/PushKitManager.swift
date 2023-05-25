//
//  PushKitManager.swift
//  APNs Helper
//
//  Created by joker on 2023/4/12.
//
#if ENABLE_PUSHKIT

import PushKit
import Combine

enum PushKitTokenType {
    case unknown
    case voip
    case fileprovider
}
typealias PushKitTokenInfo = (token: String, type: PushKitTokenType)
class PushKitManager: NSObject {

    // MARK: 单例实现
    static let shared = PushKitManager()
    private override init() {}

    // MARK: 功能
    private lazy var pushKitRegistry: PKPushRegistry = {
        let registry = PKPushRegistry(queue: .main)
#if os(iOS)
        registry.desiredPushTypes = [.voIP, .fileProvider]
#elseif os(macOS)
        registry.desiredPushTypes = [.fileProvider]
#endif
        return registry
    }()

    func setup() {
        pushKitRegistry.delegate = self
    }

    let pushKitTokenSubject = PassthroughSubject<PushKitTokenInfo, Never>()
}

extension PushKitManager: PKPushRegistryDelegate {

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {

        var pushKitTokenType: PushKitTokenType = .unknown
        switch type {
#if os(iOS)
        case .voIP:
            pushKitTokenType = .voip
#endif
        case .fileProvider:
            pushKitTokenType = .fileprovider
        default:
            pushKitTokenType = .unknown
        }
        guard pushKitTokenType != .unknown
        else {
            return
        }

        let pushKitTokenInfo: PushKitTokenInfo = (token: pushCredentials.token.hexString, type: pushKitTokenType)
        pushKitTokenSubject.send(pushKitTokenInfo)

        "pushkit token: \(pushKitTokenInfo.token) for type: \(pushKitTokenInfo.type)".printDebugInfo()
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        "pushkit token invalidate for type: \(type)".printDebugInfo()
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {

        switch type {
#if os(iOS)
        case .voIP:
            CallKitManager.shared.setupForVoip()
#endif
        case .fileProvider:
            "pushkit file provider notification received".printDebugInfo()
        default:
            break
        }

        completion()
    }
}

#endif
