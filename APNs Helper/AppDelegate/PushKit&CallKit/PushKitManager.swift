//
//  PushKitManager.swift
//  APNs Helper
//
//  Created by joker on 2023/4/12.
//

import PushKit

class PushKitManager: NSObject {
    
    // MARK: 单例实现
    static let shared = PushKitManager()
    private override init(){}
    
    // MARK: 功能
    private lazy var pushKitRegistry: PKPushRegistry = {
        let registry = PKPushRegistry(queue: .main)
        registry.desiredPushTypes = [.voIP]
        return registry
    }()
    
    func setup() {
        pushKitRegistry.delegate = self
    }
}

extension PushKitManager: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let pushKitTokenHexString = pushCredentials.token.hexString
        APNsHelperApp.model.thisAppConfig.pushKitDeviceToken = pushKitTokenHexString
        print("pushkit token: \(pushKitTokenHexString)")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        if type == .voIP {
#if DEBUG
            CallKitManager.shared.setupForVoip()
#else
            APNsHelperApp.model.toastMessage = "🎉 VoIP Push Notification Received"
#endif
        }
        completion()
    }
}
