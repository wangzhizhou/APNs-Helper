//
//  AppDelegate.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

#if os(iOS)
import UIKit
@MainActor
class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // 注册远程通知：上架版本也需要，否则无法「发给自己」并验证接收
        setupUNUserNotification()
#if DEBUG || !APNS_HELPER_SENDER
        // 接收端（Tester）始终需要这些能力；发送端只在 Debug 打开
        setupPushKitAndCallKit()
        setupFileProvider()
        setupLocationManager()
#endif
        return true
    }
}
#elseif os(macOS)
import AppKit
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 注册远程通知：上架版本也需要，否则无法「发给自己」并验证接收
        setupUNUserNotification()
#if DEBUG || !APNS_HELPER_SENDER
        setupPushKitAndCallKit()
        setupFileProvider()
#endif
    }
}
#endif
