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
    
    @StateObject var model = AppModel()
    var body: some Scene {
        WindowGroup {
            AppContent()
#if os(macOS)
                .frame(maxWidth: 632, maxHeight: 762)
#endif
                .environmentObject(model)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
#if os(macOS)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
#endif
    }
}
