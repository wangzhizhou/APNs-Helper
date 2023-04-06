//
//  AppDelegate+PKPushRegistryDelegate.swift
//  APNs Helper
//
//  Created by joker on 2023/4/6.
//
import Foundation
import CallKit
import PushKit

extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let pushKitTokenHexString = pushCredentials.token.hexString
        APNsHelperApp.model.thisAppConfig.pushKitDeviceToken = pushKitTokenHexString
        print("pushkit token: \(pushKitTokenHexString)")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        if type == .voIP {
            
            self.callProvider.setDelegate(self, queue: .main)
            
            let updateHandle = CXHandle(type: .generic, value: "VoIP Push")
            let callUpdate = CXCallUpdate()
            callUpdate.remoteHandle = updateHandle
            self.callProvider.reportNewIncomingCall(with: UUID(), update: callUpdate) { _ in }
        }
        completion()
    }
    
}
