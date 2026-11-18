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
        WindowGroup("APNs Helper") {
            AppContent()
#if os(macOS)
                .frame(minWidth: 620, minHeight: 600)
#endif
                .environment(model)
        }
#if os(macOS)
        // 不再锁死 632×828：内容可滚动、窗口可放大到全屏，避免小屏或大字号下被裁切
        .defaultSize(width: 760, height: 880)
        .windowResizability(.contentMinSize)
#endif
    }
}
