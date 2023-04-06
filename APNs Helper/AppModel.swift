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
    
    // MARK: Toast
    @Published var showToast: Bool = false
    var toastMessage: String? {
        didSet {
            if let toast = toastMessage, !toast.isEmpty {
                showToast = true
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
        
        let (valid, message) = config.isValidForSave
        guard valid else {
            alertMessage = message
            return
        }
        
        var newPresets = presets.filter { preset in
            return preset.appBundleID != config.appBundleID
        }
        let containEmptyConfig = newPresets.contains { config in
            return config.appBundleID.isEmpty;
        }
        if !containEmptyConfig {
            newPresets.insert(.invalid, at: 0)
        }
        newPresets.append(config)
        presets = newPresets
        toastMessage = "Save Preset!"
    }
    
    func clearAllPresets() {
        presets = [Config]()
        toastMessage = "Clear All Preset!"
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
            toastMessage = "Clear Exist Preset"
        }
        else {
            toastMessage = "No Preset Exist"
        }
    }
    
    // MARK: Test Mode Config
    
    @Published var thisAppConfig = Config(
        deviceToken: "",
        pushKitDeviceToken: "",
        fileProviderDeviceToken: "",
        appBundleID: Bundle.main.bundleIdentifier ?? "",
        privateKey: """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgViPOgSdnJxJ2gXfH
        iFJM4tkQhhakxYWGek6Ozwm2wkWhRANCAATiYzEZHM2oniKXJHZK123blIlSQUTp
        n2c05lXz66Ifu6eCVNoXignIS5SmDYS29CchZHQzXrinraNSTTNKgMo+
        -----END PRIVATE KEY-----
        """,
        keyIdentifier: "7S6SUT5L43",
        teamIdentifier: "2N62934Y28")
}
