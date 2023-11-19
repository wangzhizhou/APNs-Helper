//
//  ContentModel.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI

@Observable
class AppContentModel {
    var presetConfig: Config = .none
    var appInfo = Config.none
    var payload: String = ""
    var showFileImporter: Bool = false

    var isInTestMode: Bool = false
}

extension AppContentModel {

    var config: Config { appInfo.trimmed }

    func clearAppInfo() { appInfo = .none }

}
