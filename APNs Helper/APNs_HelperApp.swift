//
//  APNs_HelperApp.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import SwiftUI

@main
struct APNs_HelperApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
