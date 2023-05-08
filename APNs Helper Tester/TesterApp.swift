//
//  APNs_Helper_TesterApp.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import SwiftUI

@main
struct TesterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var model = TesterAppModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
