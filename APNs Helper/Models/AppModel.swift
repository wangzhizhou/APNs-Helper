//
//  AppModel.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation
import SwiftUI
import Combine

@Observable
class AppModel {

    // MARK: Log
    var appLog: String

    @MainActor
    func resetLog() {
        appLog = .empty
    }

    // MARK: Toast
    var showToast: Bool
    var toastModel: ToastModel {
        didSet {
            Task {
                await MainActor.run {
                    showToast = toastModel.shouldShow
                }
            }
        }
    }

    // MARK: Preset Persistence
    @AppStorage("presets")
    static private var presetData: Data = Data()

    var presets: [Config] {
        get { AppModel.presetData.toPresetConfigs.sorted(by: <) }
        set {
            if let data = newValue.data {
                AppModel.presetData = data
            }
        }
    }

    func saveConfigAsPreset(_ config: Config) -> Bool {

        let (valid, message) = config.isValid
        guard valid else {
            if let message = message {
                toastModel = ToastModel.info().title("\(message) is invalid")
            }
            return false
        }

        var newPresets = presets.filter { preset in
            return preset.appBundleID != config.appBundleID
        }
        let containEmptyConfig = newPresets.contains { config in
            return config.appBundleID.isEmpty
        }
        if !containEmptyConfig {
            newPresets.insert(.none, at: 0)
        }
        newPresets.append(config)
        presets = newPresets
        toastModel = ToastModel.info().title("Save Preset Successfully!")

        return true
    }

    func clearAllPresets() {
        presets = [Config]()
        toastModel = ToastModel.info().title("Clear All Preset Successfully!")
    }

    func clearPresetIfExist(_ config: Config) {
        var newPresets = presets
        newPresets.removeAll { preset in
            !preset.appBundleID.isEmpty && preset.appBundleID == config.appBundleID
        }
        if newPresets.count == 1, let onlyOneConfig = newPresets.last, onlyOneConfig.appBundleID == Config.none.appBundleID {
            newPresets.removeAll()
        }
        if presets.count != newPresets.count {
            presets = newPresets
            toastModel = ToastModel.info().title("Remove Exist Preset")
        } else {
            toastModel = ToastModel.info().title("No Preset Exist")
        }
    }

    // MARK: Test Mode Config
    var thisAppConfig: Config

    var isSendingPush: Bool

    init(
        appLog: String = .empty,
        showAlert: Bool  = false,
        showToast: Bool = false,
        toastModel: ToastModel = ToastModel.info(),
        thisAppConfig: Config = .thisApp,
        isSendingPush: Bool = false) {
            self.appLog = appLog
            self.showToast = showToast
            self.toastModel = toastModel
            self.thisAppConfig = thisAppConfig
            self.isSendingPush = isSendingPush

#if ENABLE_PUSHKIT
            let pushkitCancellable = PushKitManager.shared.pushKitTokenSubject.sink { pushKitTokenInfo in
                let (pushKitVoIPToken, type) = pushKitTokenInfo
                switch type {
                case .voip:
                    self.thisAppConfig.pushKitVoIPToken = pushKitVoIPToken
                case .fileprovider:
                    self.thisAppConfig.pushKitFileProviderToken = pushKitVoIPToken
                default:
                    break
                }
            }
            cancellables.append(pushkitCancellable)
#endif

            let deviceTokenCancellable = UNUserNotificationManager.shared.deviceTokenSubject.sink { deviceToken in
                self.thisAppConfig.deviceToken = deviceToken
            }
            cancellables.append(deviceTokenCancellable)

            let backgroundNotificationCancellable = UNUserNotificationManager.shared.backgroundNotificationSubject.sink { message in
                self.toastModel = ToastModel.info().title(message)
            }
            cancellables.append(backgroundNotificationCancellable)

            let copyToPasteboardCancellable = NotificationCenter.default.publisher(for: .APNSHelperStringCopyedToPastedboard).sink { _ in
                self.toastModel = ToastModel.info().title("Copyed to Pasteboard!")
            }
            cancellables.append(copyToPasteboardCancellable)

            CodeFomater.setup()
        }

    private var cancellables = [AnyCancellable]()
}
