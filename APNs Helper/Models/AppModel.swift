//
//  AppModel.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation
import SwiftUI
import Combine
import SwiftData

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

    @MainActor
    var presets: [Config] {
        let fetchDescriptor = FetchDescriptor<Config>(sortBy: [.init(\.appBundleID)])
        let savedPresets = try? modelContainer.mainContext.fetch(fetchDescriptor)
        return savedPresets ?? []
    }

    @MainActor
    func saveConfigAsPreset(_ config: Config) -> Bool {

        let (valid, message) = config.isValid
        guard valid else {
            if let message = message {
                toastModel = ToastModel.info().title("\(message) is invalid")
            }
            return false
        }
        
        do {
            modelContainer.mainContext.insert(Config.none)
            modelContainer.mainContext.insert(config)
            try modelContainer.mainContext.save()
            toastModel = ToastModel.info().title("Save Preset Successfully!")
            return true
        } catch {
            print(error)
            return false
        }
    }

    @MainActor
    func clearAllPresets() {
        do {
            try modelContainer.mainContext.delete(model: Config.self)
            toastModel = ToastModel.info().title("Clear All Preset Successfully!")
        } catch {
            fatalError("clear all preset failed!!!")
        }
    }

    @MainActor
    func clearPresetIfExist(_ config: Config) {
        modelContainer.mainContext.delete(config)
        toastModel = ToastModel.info().title("Remove Exist Preset")
    }

    // MARK: Test Mode Config
    var thisAppConfig: Config

    var isSendingPush: Bool
    
    let modelContainer: ModelContainer
     
    init(
        appLog: String = .empty,
        showAlert: Bool  = false,
        showToast: Bool = false,
        toastModel: ToastModel = ToastModel.info(),
        isSendingPush: Bool = false) {
            
            do {
                try modelContainer = ModelContainer(for: Config.self)
            } catch {
                fatalError("Could not initialize ModelContainer")
            }
            
            self.appLog = appLog
            self.showToast = showToast
            self.toastModel = toastModel
            self.thisAppConfig = .thisApp
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
