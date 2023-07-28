//
//  ContentModel.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI

class AppContentModel: ObservableObject {
    @Published var presetConfig: Config = .none
    @Published var appInfo = Config.none
    @Published var payload: String = ""
    @Published var showFileImporter: Bool = false

    @Published var isInTestMode: Bool = false
}

extension AppContentModel {

    var config: Config { appInfo.trimmed }

    func clearAppInfo() { appInfo = .none }

}
