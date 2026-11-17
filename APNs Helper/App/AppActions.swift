//
//  AppActions.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import SwiftUI

/// `AppContent` 提供给 iOS / macOS 两套布局的操作集合。
///
/// 之前这些操作是 6 个独立的初始化参数，平台分支视图的初始化列表越来越长；
/// 收敛成一个值通过 Environment 传递后，新增操作不需要改动调用方签名。
struct AppActions {

    var loadPayloadTemplate: () -> Void = {}
    var saveAsPreset: () -> Void = {}
    var clearAllPreset: () -> Void = {}
    var clearCurrentConfigPresetIfExist: () -> Void = {}
    var importAppInfoOnPasteboard: () -> Void = {}
    var refreshTestMode: () -> Void = {}
}

extension EnvironmentValues {

    @Entry var appActions = AppActions()
}
