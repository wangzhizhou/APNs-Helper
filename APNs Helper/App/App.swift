//
//  APNsHelperApp.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import SwiftUI

@main
struct APNsHelperApp: App {

#if os(macOS) && DEBUG
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
#if os(iOS) && DEBUG
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif

    var body: some Scene {

#if os(macOS) && true
        MacOSScene()
#else
        AppScene()
#endif
    }
}
