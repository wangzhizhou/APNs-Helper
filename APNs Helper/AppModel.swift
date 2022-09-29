//
//  AppModel.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation

class AppModel: ObservableObject {
    
    @Published var appLog: String = ""
    
    @Published var presets: [Config] = [
        .invalid,
        .f100,
        .f100InHouse,
        .f101,
        .f101InHouse
    ]
    
    @MainActor
    func resetLog() {
        appLog = ""
    }
}
