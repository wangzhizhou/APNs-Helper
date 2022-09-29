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
    
    static let model = AppModel()
    
    var body: some Scene {
        WindowGroup {
            AppContent()
                .environmentObject(Self.model)
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
        }
    }
}
