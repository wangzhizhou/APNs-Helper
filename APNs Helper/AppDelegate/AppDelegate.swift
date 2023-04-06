//
//  AppDelegate.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import UIKit
import PushKit
import CallKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
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
        APNsHelperApp.model.thisAppConfig.deviceToken = deviceTokenHexString
        print("device token: \(deviceTokenHexString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("register device token failed. \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if userInfo.keys.contains("aps"), let aps = userInfo["aps"] as? [AnyHashable: Any], aps.keys.count == 1, aps.keys.contains("content-available"), let contentAvailable = aps["content-available"] as? Bool, contentAvailable {
            APNsHelperApp.model.toastMessage = "🔊 Background Notification Received"
        }
        
        completionHandler(.newData)
    }
}
