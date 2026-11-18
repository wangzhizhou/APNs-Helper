//
//  AppModel.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation
import SwiftUI
import Combine
import Observation

@Observable
@MainActor
final class AppModel {

    // MARK: Log
    var appLog: String

    func resetLog() {
        appLog = .empty
    }

    // MARK: Toast
    var showToast: Bool
    var toastModel: ToastModel {
        didSet {
            showToast = toastModel.shouldShow
        }
    }

    // MARK: Preset Persistence

    /// 预设里含 `.p8` 与 device token，属于凭据 → 存 Keychain。
    /// 旧版本存在 UserDefaults，首次访问时迁移并清理。
    private static let presetsAccount = "presets"
    private static let legacyPresetsKey = "presets"

    private var presetData: Data {
        get {
            if let data = KeychainStore.data(for: Self.presetsAccount) {
                return data
            }
            guard let legacy = UserDefaults.standard.data(forKey: Self.legacyPresetsKey) else {
                return Data()
            }
            try? KeychainStore.set(legacy, for: Self.presetsAccount)
            UserDefaults.standard.removeObject(forKey: Self.legacyPresetsKey)
            return legacy
        }
        set {
            do {
                try KeychainStore.set(newValue, for: Self.presetsAccount)
            } catch {
                appLog.append("\n[save preset failed] \(error.localizedDescription)\n")
            }
        }
    }

    var presets: [Config] {
        get { presetData.toPresetConfigs.sorted(by: <) }
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
        presetData: Data = Data(),
        thisAppConfig: Config = .thisApp,
        isSendingPush: Bool = false) {
            self.appLog = appLog
            self.showToast = showToast
            self.toastModel = toastModel
            self.thisAppConfig = thisAppConfig
            if !presetData.isEmpty {
                try? KeychainStore.set(presetData, for: Self.presetsAccount)
            }
            self.isSendingPush = isSendingPush

#if ENABLE_PUSHKIT
            let pushkitCancellable = PushKitManager.shared.pushKitTokenSubject.sinkOnMain { pushKitTokenInfo in
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

            let deviceTokenCancellable = UNUserNotificationManager.shared.deviceTokenSubject.sinkOnMain { deviceToken in
                self.thisAppConfig.deviceToken = deviceToken
            }
            cancellables.append(deviceTokenCancellable)

            let backgroundNotificationCancellable = UNUserNotificationManager.shared.backgroundNotificationSubject.sinkOnMain { payload in
                self.appLog.append("\n[Received Notification]\n\(payload)\n")
                self.toastModel = ToastModel.info().title("Notification Received")
            }
            cancellables.append(backgroundNotificationCancellable)

            let notificationErrorCancellable = UNUserNotificationManager.shared.errorSubject
                .sinkOnMain { message in
                    self.appLog.append("\n[Notification] \(message)\n")
                    self.toastModel = ToastModel.info().title("Notification Error")
                }
            cancellables.append(notificationErrorCancellable)

            let copyToPasteboardCancellable = NotificationCenter.default
                .publisher(for: .APNSHelperStringCopyedToPastedboard)
                .sinkOnMain { _ in
                self.toastModel = ToastModel.info().title("Copyed to Pasteboard!")
            }
            cancellables.append(copyToPasteboardCancellable)

            CodeFomater.setup()
        }

    private var cancellables = [AnyCancellable]()
}
