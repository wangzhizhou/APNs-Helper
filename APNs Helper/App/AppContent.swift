//
//  AppContent.swift
//  APNs Helper
//
//  Created by joker on 2022/9/28.
//

import SwiftUI
import AlertToast

struct AppContent: View {
    
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
                refreshTestMode: refreshTestMode)
#elseif os(macOS)
            AppContentMacOS(
                loadPayloadTemplate: loadPayloadTemplate,
                saveAsPreset: saveAsPreset,
                clearAllPreset: clearAllPreset,
                clearCurrentConfigPresetIfExist: clearCurrentConfigPresetIfExist)
#endif
        }
        .background(.background)
        .environmentObject(contentModel)
        .onAppear {
            loadPayloadTemplate()
        }
        .toast(isPresenting: $appModel.showToast) {
            AlertToast(displayMode: .hud, type: .regular, title: appModel.toastMessage, style: .style(backgroundColor: .orange))
        }
    }
}

extension AppContent {
    
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
