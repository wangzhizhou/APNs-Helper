//
//  AppModel.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation

class AppModel: ObservableObject {
    
    @Published var appLog: String = ""
    
#if DEBUG
    @Published var presets: [Config] = [
        .invalid,
        .f100,
        .f100InHouse,
        .f101,
        .f101InHouse,
        .jokerhub
    ]
#else
    @Published var presets = [Config]()
#endif

    @MainActor
    func resetLog() {
        appLog = ""
    }
}
