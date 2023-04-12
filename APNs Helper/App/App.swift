//
//  APNsHelperApp.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import SwiftUI

@main
struct APNsHelperApp: App {
#if os(iOS) && DEBUG
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    let persistenceController = PersistenceController.preview
    static let model = AppModel()
    var body: some Scene {
        WindowGroup {
            AppContent()
                .environmentObject(Self.model)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
#if os(macOS)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
#endif
    }
}
