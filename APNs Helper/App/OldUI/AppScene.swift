//
//  AppScene.swift
//  APNs Helper
//
//  Created by joker on 2024/4/29.
//

import SwiftUI

struct AppScene: Scene {

    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            AppContent()
#if os(macOS)
                .frame(maxWidth: 632, minHeight: 828, maxHeight: 828)
#endif
                .environment(model)
                .modelContainer(model.modelContainer)
        }
#if os(macOS)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
#endif
    }
}
