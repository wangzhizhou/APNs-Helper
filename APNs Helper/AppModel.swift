//
//  AppModel.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation

class AppModel: ObservableObject {
    
    @Published var appLog: String = ""
    
    @MainActor
    func resetLog() {
        appLog = ""
    }
}
