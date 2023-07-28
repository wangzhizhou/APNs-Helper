//
//  APNs_Helper_TesterApp.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import SwiftUI

@main
struct TesterApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif

#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif

    @StateObject var model = TesterAppModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
#if os(macOS)
                .frame(minWidth: 632, maxWidth: 632, minHeight: 500, maxHeight: 500)
#endif
        }
#if os(macOS)
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
#endif
    }
}
