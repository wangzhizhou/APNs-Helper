//
//  ContentModel.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI
import Observation

@Observable
final class AppContentModel {
    var presetConfig: Config = .none
    var appInfo = Config.none
    var payload: String = ""
    var showFileImporter: Bool = false

    /// 从剪贴板导入前的确认（剪贴板可能含 .p8 等凭据）
    var showPasteboardImportConfirm: Bool = false

    /// 结构化 Payload 编辑器（alert / live activity）
    var showStructuredEditor: Bool = false

    /// 当前 push type 是否支持结构化编辑
    var supportsStructuredEditor: Bool {
        switch appInfo.pushType {
        case .alert, .liveactivity: return true
        default: return false
        }
    }

    var isInTestMode: Bool = false
}

extension AppContentModel {

    var config: Config { appInfo.trimmed }

    func clearAppInfo() { appInfo = .none }

    /// 「Fill this App's Info」开关切换：打开时填入本 App 的配置，关闭时清空。
    func applyTestMode(_ enabled: Bool, thisAppConfig: Config) {
        appInfo = enabled ? thisAppConfig : .none
    }

    /// 本 App 的配置变化（如收到新的 device token）时，若处于测试模式则同步过来。
    func syncWithTestConfig(_ thisAppConfig: Config) {
        guard isInTestMode else { return }
        appInfo = thisAppConfig
    }

}
