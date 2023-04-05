//
//  AppModel.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation
import SwiftUI

class AppModel: ObservableObject {
    
    // MARK: Log
    @Published var appLog: String = ""

    @MainActor
    func resetLog() {
        appLog = ""
    }
    
    // MARK: Alert
    
    @Published var showAlert: Bool = false
    var alertMessage: String? {
        didSet {
            if let message = alertMessage, !message.isEmpty {
                showAlert = true
            }
        }
    }
    
    // MARK: Preset Persistence
    
    @AppStorage("presets")
    private var presetData: Data = Data()
    
    var presets: [Config] {
        get { presetData.toPresetConfigs }
        set {
            if let data = newValue.data {
                presetData = data
            }
        }
    }

    func saveConfigAsPreset(_ config: Config) {
        guard !config.keyIdentifier.isEmpty else {
            alertMessage = "KeyID is Empty"
            return
        }
        guard !config.teamIdentifier.isEmpty else {
            alertMessage = "TeamID is Empty"
            return
        }
        guard !config.appBundleID.isEmpty else {
            alertMessage = "BundleID is Empty"
            return
        }
        guard !config.privateKey.isEmpty else {
            alertMessage = "Private Key is Empty"
            return
        }
        var newPresets = presets
        let containEmptyConfig = newPresets.contains(where: { config in
            return config.appBundleID.isEmpty;
        })
        if !containEmptyConfig {
            newPresets.insert(.invalid, at: 0)
        }
        newPresets.append(config)
        presets = newPresets
        alertMessage = "Save Preset Successfully!"
    }
    
    func clearPresets() {
        presets = [Config]()
        alertMessage = "Clear Preset Successfully!"
    }
    
    func clearPresetIfExist(_ config: Config) {
        var newPresets = presets
        newPresets.removeAll { preset in
            !preset.appBundleID.isEmpty && preset.appBundleID == config.appBundleID
        }
        if newPresets.count == 1, let onlyOneConfig = newPresets.last,
           onlyOneConfig.appBundleID == Config.invalid.appBundleID {
            newPresets.removeAll()
        }
        if presets.count != newPresets.count {
            presets = newPresets
            alertMessage = "Clear Exist Preset"
        }
        else {
            alertMessage = "No Preset Exist"
        }
    }
}
