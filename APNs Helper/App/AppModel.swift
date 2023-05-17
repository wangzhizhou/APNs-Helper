//
//  AppModel.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation
import SwiftUI
import Combine

class AppModel: ObservableObject {
    
    // MARK: Log
    @Published var appLog: String
    
    @MainActor
    func resetLog() {
        appLog = .empty
    }
        
    // MARK: Toast
    @Published var showToast: Bool
    var toastMessage: String? {
        didSet {
            if let toast = toastMessage, !toast.isEmpty {
                Task {
                    await MainActor.run {
                        showToast = true
                    }                    
                }
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
    
    func saveConfigAsPreset(_ config: Config) -> Bool {
        
        let (valid, message) = config.isValid
        guard valid else {
            if let message = message {
                toastMessage = "\(message) is invalid"
            }
            return false
        }
        
        var newPresets = presets.filter { preset in
            return preset.appBundleID != config.appBundleID
        }
        let containEmptyConfig = newPresets.contains { config in
            return config.appBundleID.isEmpty;
        }
        if !containEmptyConfig {
            newPresets.insert(.none, at: 0)
        }
        newPresets.append(config)
        presets = newPresets
        toastMessage = "Save Preset Successfully!"
        
        return true
    }
    
    func clearAllPresets() {
        presets = [Config]()
        toastMessage = "Clear All Preset Successfully!"
    }
    
    func clearPresetIfExist(_ config: Config) {
        var newPresets = presets
        newPresets.removeAll { preset in
            !preset.appBundleID.isEmpty && preset.appBundleID == config.appBundleID
        }
        if newPresets.count == 1, let onlyOneConfig = newPresets.last,
           onlyOneConfig.appBundleID == Config.none.appBundleID {
            newPresets.removeAll()
        }
        if presets.count != newPresets.count {
            presets = newPresets
            toastMessage = "Remove Exist Preset"
        }
        else {
            toastMessage = "No Preset Exist"
        }
    }
    
    // MARK: Test Mode Config
    
    @Published var thisAppConfig = Config(
        deviceToken: .empty,
        pushKitDeviceToken: .empty,
        fileProviderDeviceToken: .empty,
        appBundleID: Bundle.main.bundleIdentifier ?? .empty,
        privateKey: """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgViPOgSdnJxJ2gXfH
        iFJM4tkQhhakxYWGek6Ozwm2wkWhRANCAATiYzEZHM2oniKXJHZK123blIlSQUTp
        n2c05lXz66Ifu6eCVNoXignIS5SmDYS29CchZHQzXrinraNSTTNKgMo+
        -----END PRIVATE KEY-----
        """,
        keyIdentifier: "7S6SUT5L43",
        teamIdentifier: "2N62934Y28")
    
    @MainActor
    var isSendingPush: Bool
    
    init(
        appLog: String = .empty,
        showAlert: Bool  = false,
        showToast: Bool = false,
        toastMessage: String? = nil,
        presetData: Data = Data(),
        thisAppConfig: Config = Config(
            deviceToken: .empty,
            pushKitDeviceToken: .empty,
            fileProviderDeviceToken: .empty,
            appBundleID: Bundle.main.bundleIdentifier ?? .empty,
            privateKey: """
            -----BEGIN PRIVATE KEY-----
            MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgViPOgSdnJxJ2gXfH
            iFJM4tkQhhakxYWGek6Ozwm2wkWhRANCAATiYzEZHM2oniKXJHZK123blIlSQUTp
            n2c05lXz66Ifu6eCVNoXignIS5SmDYS29CchZHQzXrinraNSTTNKgMo+
            -----END PRIVATE KEY-----
            """,
            keyIdentifier: "7S6SUT5L43",
            teamIdentifier: "2N62934Y28"),
        isSendingPush: Bool = false) {
            self.appLog = appLog
            self.showToast = showToast
            self.toastMessage = toastMessage
            self.presetData = presetData
            self.thisAppConfig = thisAppConfig
            self.isSendingPush = isSendingPush
            
#if ENABLE_PUSHKIT
            let pushkitCancellable = PushKitManager.shared.pushKitTokenSubject.sink { pushKitToken in
                self.thisAppConfig.pushKitDeviceToken = pushKitToken
            }
            cancellables.append(pushkitCancellable)
#endif
            
            let deviceTokenCancellable = UNUserNotificationManager.shared.deviceTokenSubject.sink { deviceToken in
                self.thisAppConfig.deviceToken = deviceToken
            }
            cancellables.append(deviceTokenCancellable)
            
            let backgroundNotificationCancellable = UNUserNotificationManager.shared.backgroundNotificationSubject.sink { message in
                self.toastMessage = message
            }
            cancellables.append(backgroundNotificationCancellable)
            
            let copyToPasteboardCancellable = NotificationCenter.default.publisher(for: .APNSHelperStringCopyedToPastedboard).sink { _ in
                self.toastMessage = "Copyed to Pasteboard!"
            }
            cancellables.append(copyToPasteboardCancellable)
            
            CodeFomater.setup()
        }
    
    private var cancellables = [AnyCancellable]()
}
