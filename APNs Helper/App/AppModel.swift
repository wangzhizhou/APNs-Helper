//
//  AppModel.swift
//  APNs Helper
//
//  Created by joker on 2022/9/24.
//

import Foundation
import SwiftUI
import Combine
import AnyCodable
import Logging

@MainActor
@Observable
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
    // MARK: Test Mode Config
    var thisAppInfo: AppInfo
    
    var isSendingPush: Bool
    
    let modelContainer: ModelContainer
    
    @ObservationIgnored
    lazy var logger = {
        Logger(label: "APNs Helper") { _ in
            AppLogHandler(appModel: self)
        }
    }()
    
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
            self.thisAppInfo = .thisAppInfo
            self.isSendingPush = isSendingPush
            
#if ENABLE_PUSHKIT
            let pushkitCancellable = PushKitManager.shared.pushKitTokenSubject.sink { pushKitTokenInfo in
                let (pushKitToken, type) = pushKitTokenInfo
                switch type {
                case .voip:
                    self.thisAppInfo.voipToken = pushKitToken
                case .fileprovider:
                    self.thisAppInfo.fileProviderToken = pushKitToken
                default:
                    break
                }
            }
            cancellables.append(pushkitCancellable)
#endif
            
            let deviceTokenCancellable = UNUserNotificationManager.shared.deviceTokenSubject.sink { deviceToken in
                self.thisAppInfo.deviceToken = deviceToken
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

// MARK: 发送通知
extension AppModel {
    func sendPush(with content: AppContentModel, payload: AnyCodable) async throws {
        let apnService = APNsService(
            appInfo: content.appInfo,
            pushType: content.pushType,
            apnsServerEnv: content.apnsServerEnv,
            payload: payload
        )
        do {
            logger.critical("Start Sending Push\n")
            let apnsID = try await apnService.send()
            logger.critical("Send Push Success!\napnsID: \(apnsID?.uuidString ?? "None")")
            self.isSendingPush = false
        } catch let error as APNServiceError {
            self.isSendingPush = false
            switch error {
            case .notReachable:
                self.toastModel = ToastModel.info().title("APN Server Not Reachable")
            }
        } catch let error {
            self.isSendingPush = false
            logger.error("Send Push Failed!", metadata: ["error": "\(error)"])
        }
    }
}

// MARK: 持久化
import SwiftData
extension AppModel {
    
    var presets: [AppInfo] {
        let fetchDescriptor = FetchDescriptor<Config>(sortBy: [.init(\.appBundleID)])
        let savedPresets = try? modelContainer.mainContext.fetch(fetchDescriptor)
        return savedPresets?.compactMap { $0.appInfo } ?? []
    }
    
    func saveConfigAsPreset(_ appInfo: AppInfo) -> Bool {
        
        let (valid, message) = appInfo.isValid
        guard valid else {
            if let message = message {
                toastModel = ToastModel.info().title("\(message) is invalid")
            }
            return false
        }
        
        do {
            modelContainer.mainContext.insert(AppInfo.none.toConfig)
            modelContainer.mainContext.insert(appInfo.toConfig)
            try modelContainer.mainContext.save()
            toastModel = ToastModel.info().title("Save Preset Successfully!")
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func clearAllPresets() {
        do {
            try modelContainer.mainContext.delete(model: Config.self)
            try modelContainer.mainContext.save()
            toastModel = ToastModel.info().title("Clear All Preset Successfully!")
        } catch {
            fatalError("clear all preset failed!!!")
        }
    }
    
    func clearPresetIfExist(_ appInfo: AppInfo) {
        let appBundleID = appInfo.bundleID
        do {
            try modelContainer.mainContext.delete(model: Config.self, where: #Predicate {
                $0.appBundleID == appBundleID
            })
            toastModel = ToastModel.info().title("Remove Exist Preset")
        } catch let error {
            error.localizedDescription.printDebugInfo()
            fatalError("delete preset failed!!!")
        }
    }
}
