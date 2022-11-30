//
//  APNs_Helper_TesterApp.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import SwiftUI

@main
struct TesterApp: App {
    
    @UIApplicationDelegateAdaptor(TesterAppDelegate.self) var appDelegate
    
    static let model = TesterAppModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .navigationTitle("Tester App")
                    .environmentObject(TesterApp.model)
            }
        }
    }
}
