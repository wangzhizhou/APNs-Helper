//
//  APNsHelperApp.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import SwiftUI

@main
struct APNsHelperApp: App {
//    let persistenceController = PersistenceController.shared
    
    let model = AppModel()

    var body: some Scene {
        WindowGroup {
            AppContent()
                .environmentObject(model)
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
        }
    }
}
