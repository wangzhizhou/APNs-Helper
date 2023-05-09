//
//  AppContent.swift
//  APNs Helper
//
//  Created by joker on 2022/9/28.
//

import SwiftUI
import UniformTypeIdentifiers

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
        .environmentObject(contentModel)
        .onAppear {
            loadPayloadTemplate()
        }
        .alert(isPresented: $appModel.showAlert) {
            Alert(title: Text(appModel.alertMessage ?? ""))
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
        guard appModel.thisAppConfig.isValidForSave.valid
        else { return }
        contentModel.isInTestMode = (contentModel.config == appModel.thisAppConfig)
    }
}

struct AppContent_Previews: PreviewProvider {
    static var previews: some View {
        AppContent()
            .environmentObject(AppModel())
    }
}
