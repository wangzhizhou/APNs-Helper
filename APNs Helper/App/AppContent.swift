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
    
    @EnvironmentObject var appModel: AppModel
    
    @StateObject
    private var contentModel = AppContentModel()
    
    var body: some View {
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
        .environmentObject(contentModel)
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
        .onChange(of: scenePhase) { scenePhase in
            switch scenePhase {
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
        
        var pasteboardContent: String? = nil
#if os(macOS)
        pasteboardContent = NSPasteboard.general.string(forType: .string)
#elseif os(iOS)
        pasteboardContent = UIPasteboard.general.string
#endif
        guard let appInfoJson = pasteboardContent, let appInfo = AppInfo.decode(from: appInfoJson)
        else {
            appModel.toastModel = ToastModel.info().title("No App Info on pasteboard!")
            return
        }
        contentModel.appInfo.keyIdentifier = appInfo.keyID
        contentModel.appInfo.teamIdentifier = appInfo.teamID
        contentModel.appInfo.appBundleID = appInfo.bundleID
        contentModel.appInfo.privateKey = appInfo.p8Key
        contentModel.appInfo.deviceToken = appInfo.deviceToken
        contentModel.appInfo.pushKitVoIPToken = appInfo.voipToken
        contentModel.appInfo.pushKitFileProviderToken = appInfo.fileProviderToken
    }
    
    func loadPayloadTemplate() {
        if let template = APNsService.templatePayload(for: contentModel.config) {
            contentModel.payload = template
        }
    }
    
    func saveAsPreset() {
        if appModel.saveConfigAsPreset(contentModel.config) {
            contentModel.presetConfig = contentModel.config
        }
    }
    
    func clearAllPreset() {
        appModel.clearAllPresets()
    }
    
    func clearCurrentConfigPresetIfExist() {
        appModel.clearPresetIfExist(contentModel.config)
    }
    
    func refreshTestMode() {
        guard appModel.thisAppConfig.isValid.valid
        else { return }
        contentModel.isInTestMode = (contentModel.config == appModel.thisAppConfig)
    }
}

struct AppContent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppContent()
                .previewDevice("My Mac")
                .previewDisplayName("MacOS")
            
            AppContent()
                .previewDevice("iPhone 14 Pro Max")
                .previewDisplayName("iOS")
        }
        .environmentObject(AppModel())
    }
}
