//
//  MacOSScene.swift
//  APNs Helper
//
//  Created by joker on 2024/4/29.
//

import SwiftUI

struct MacOSScene: Scene {

    @State private var model = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
        }
        .windowResizability(.contentSize)


        Settings {
            SettingsView()
        }
        .windowResizability(.contentSize)
    }
}
