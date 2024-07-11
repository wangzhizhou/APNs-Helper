//
//  AppContent.swift
//  APNs Helper
//
//  Created by joker on 2022/9/28.
//

import SwiftUI
import AlertToast

struct AppContent: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @Environment(AppModel.self) private var appModel
    
    @State private var contentModel = AppContentModel()
    
    var body: some View {
        @Bindable var appModel = appModel
        VStack {
#if os(iOS)
            AppContentIOS(
                loadPayloadTemplate: loadPayloadTemplate,
                saveAsPreset: saveAsPreset,
                clearAllPreset: clearAllPreset,
                clearCurrentConfigPresetIfExist: clearCurrentConfigPresetIfExist,
                importAppInfoOnPasteboard: fillAppInfoFromPasteboard,
                refreshTestMode: refreshTestMode
            )
#elseif os(macOS)
            AppContentMacOS(
                loadPayloadTemplate: loadPayloadTemplate,
                saveAsPreset: saveAsPreset,
                clearAllPreset: clearAllPreset,
                clearCurrentConfigPresetIfExist: clearCurrentConfigPresetIfExist,
                importAppInfoOnPasteboard: fillAppInfoFromPasteboard,
                refreshTestMode: refreshTestMode
            )
#endif
        }
        .background(.background)
        .environment(contentModel)
        .onAppear {
            loadPayloadTemplate()
        }
        .toast(isPresenting: $appModel.showToast) {
            AlertToast(
                displayMode: appModel.toastModel.mode,
                type: appModel.toastModel.type,
                title: appModel.toastModel.title,
                subTitle: appModel.toastModel.subtitle,
                style: appModel.toastModel.style)
        }
        .onChange(of: scenePhase) { _, newValue in
            switch newValue {
            case .active:
                break
            case .background:
                break
            case .inactive:
                break
            default:
                break
            }
        }
    }
}

extension AppContent {
    
    func fillAppInfoFromPasteboard() {
        
        var pasteboardContent: String?
#if os(macOS)
        pasteboardContent = NSPasteboard.general.string(forType: .string)
#elseif os(iOS)
        pasteboardContent = UIPasteboard.general.string
#endif
        guard let appInfoJson = AppInfo.jsonStringFromFormattedText(pasteboardContent), let appInfo = AppInfo.decode(from: appInfoJson)
        else {
            appModel.toastModel = ToastModel.info().title("No App Info on pasteboard!")
            return
        }
        
        contentModel.appInfo = Config(
            deviceToken: appInfo.deviceToken,
            pushKitVoIPToken: appInfo.voipToken,
            pushKitFileProviderToken: appInfo.fileProviderToken,
            locationPushServiceToken: appInfo.locationPushToken,
            liveActivityPushToken: appInfo.liveActivityPushToken,
            appBundleID: appInfo.bundleID,
            privateKey: appInfo.p8Key,
            keyIdentifier: appInfo.keyID,
            teamIdentifier: appInfo.teamID
        )
    }
    
    func loadPayloadTemplate() {
        if let template = contentModel.config.jsonPayload {
            contentModel.payload = template
        }
    }
    
    func saveAsPreset() {
        Task {
            await MainActor.run {
                if appModel.saveConfigAsPreset(contentModel.config) {
                    contentModel.presetConfig = contentModel.config
                }
            }
        }
    }
    
    func clearAllPreset() {
        Task {
            await MainActor.run {
                appModel.clearAllPresets()
            }
        }
    }
    
    func clearCurrentConfigPresetIfExist() {
        Task {
            await MainActor.run {
                appModel.clearPresetIfExist(contentModel.presetConfig)
            }
        }
    }
    
    func refreshTestMode() {
        guard appModel.thisAppConfig.isValid.valid
        else { return }
        contentModel.isInTestMode = (contentModel.config == appModel.thisAppConfig)
    }
}

#Preview {
    AppContent()
        .environment(AppModel())
}
