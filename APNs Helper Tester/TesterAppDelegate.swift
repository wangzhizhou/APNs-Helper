//
//  TesterAppDelegate.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import UIKit
import UserNotifications
import PushKit
import CallKit

class TesterAppDelegate: NSObject, UIApplicationDelegate {
    
    lazy var pushKitRegistry: PKPushRegistry = {
        let registry = PKPushRegistry(queue: .main)
        registry.desiredPushTypes = [.voIP]
        return registry
    }()
    
    lazy var callProvider: CXProvider = {
        var config = CXProviderConfiguration()
        config.supportsVideo = false
        config.supportedHandleTypes = [CXHandle.HandleType.generic]
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        config.includesCallsInRecents = false
        let provider = CXProvider(configuration: config)
        return provider
    }()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {_,_ in }
        UNUserNotificationCenter.current().delegate = self
        
        application.registerForRemoteNotifications()
        
        self.pushKitRegistry.delegate = self

        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenHexString = deviceToken.hexString
        TesterApp.model.deviceToken = deviceTokenHexString
        print("device token: \(deviceTokenHexString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("register device token failed. \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if userInfo.keys.contains("aps"), let aps = userInfo["aps"] as? [AnyHashable: Any], aps.keys.count == 1, aps.keys.contains("content-available"), let contentAvailable = aps["content-available"] as? Bool, contentAvailable {
            TesterApp.model.alertMessage = "🔊 Background Notification Received"
        }
        
        completionHandler(.newData)
    }
}


extension TesterAppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .list, .banner])
    }
    
}

extension TesterAppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let pushKitTokenHexString = pushCredentials.token.hexString
        TesterApp.model.pushKitToken = pushKitTokenHexString
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

extension TesterAppDelegate: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        
        let endCallAction = CXEndCallAction(call: action.callUUID)
        let transaction = CXTransaction(action: endCallAction)
        CXCallController().request(transaction) { _ in }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        action.fulfill()
    }
}

extension Data {
    var hexString: String { reduce("") { $0 + String(format: "%02x", $1) } }
}
