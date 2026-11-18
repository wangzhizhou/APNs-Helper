//
//  APNsHelperApp.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import SwiftUI

@main
struct APNsHelperApp: App {
    // 自收发（发给自己并验证接收）是本工具的核心用途，Release 构建同样需要注册远程通知
#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif

    @State private var model = AppModel()
    var body: some Scene {
        WindowGroup {
            AppContent()
#if os(macOS)
                .frame(maxWidth: 632, minHeight: 828, maxHeight: 828)
#endif
                .environment(model)
        }
#if os(macOS)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
#endif
    }
}
