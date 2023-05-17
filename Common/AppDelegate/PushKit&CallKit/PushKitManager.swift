//
//  PushKitManager.swift
//  APNs Helper
//
//  Created by joker on 2023/4/12.
//
#if ENABLE_PUSHKIT

import PushKit
import Combine

class PushKitManager: NSObject {
    
    // MARK: 单例实现
    static let shared = PushKitManager()
    private override init(){}
    
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
    
    let pushKitTokenSubject = PassthroughSubject<String, Never>()
}

extension PushKitManager: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let pushKitTokenHexString = pushCredentials.token.hexString
        pushKitTokenSubject.send(pushKitTokenHexString)
        pushKitTokenSubject.send(completion: .finished)
        
        "pushkit token: \(pushKitTokenHexString)".printDebugInfo()
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        switch type {
#if os(iOS)
        case .voIP:
            CallKitManager.shared.setupForVoip()
#endif
        case .fileProvider:
            break
        default:
            break
        }
        
        completion()
    }
}

#endif
