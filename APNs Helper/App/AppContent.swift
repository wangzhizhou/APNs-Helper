//
//  AppContent.swift
//  APNs Helper
//
//  Created by joker on 2022/9/28.
//

import SwiftUI

struct AppContent: View {
    
    @EnvironmentObject var appModel: AppModel
    
    @State var presetConfig: Config = .none
    @State var teamIdentifier: String = ""
    @State var keyIdentifier: String = ""
    @State var appBundleID: String = ""
    @State var deviceToken: String = ""
    @State var pushKitDeviceToken: String = ""
    @State var fileProviderDeviceToken: String = ""
    @State var privateKey: String = ""
    @State var pushType: PushType = .alert
    @State var apnsServerEnv: APNServerEnv = .sandbox
    @State var payload: String = ""
    
    @State var simulator: Bool = false
    @State var isPresented: Bool = false
    
    @State var showFileImporter: Bool = false
    @State var isInTestMode: Bool = false
    @FocusState var logTextEditorFocusState: Bool

    var config: Config {
        .init(
            deviceToken: deviceToken.trimmed,
            pushKitDeviceToken: pushKitDeviceToken.trimmed,
            fileProviderDeviceToken: fileProviderDeviceToken.trimmed,
            appBundleID: appBundleID.trimmed,
            privateKey: privateKey,
            keyIdentifier: keyIdentifier.trimmed,
            teamIdentifier: teamIdentifier.trimmed,
            pushType:pushType,
            apnsServerEnv: apnsServerEnv,
            sendToSimulator: simulator
        )
    }
    
    func loadPayloadTemplate() {
        if let template = APNsService.templatePayload(for: config) {
            payload = template
        }
    }
    
    func saveAsPreset() {
        if appModel.saveConfigAsPreset(self.config) {
            presetConfig = self.config
        }
    }
    
    func clearAllPreset() {
        appModel.clearAllPresets()
    }
    
    func clearCurrentConfigPresetIfExist() {
        appModel.clearPresetIfExist(self.config)
    }
    
    func clearAppInfo() {
        keyIdentifier = ""
        teamIdentifier = ""
        appBundleID = ""
        privateKey = ""
        deviceToken = ""
        pushKitDeviceToken = ""
        fileProviderDeviceToken = ""
    }
    
    func configThisAppInfo() {
        keyIdentifier = appModel.thisAppConfig.keyIdentifier
        teamIdentifier = appModel.thisAppConfig.teamIdentifier
        appBundleID = appModel.thisAppConfig.appBundleID
        privateKey = appModel.thisAppConfig.privateKey
        deviceToken = appModel.thisAppConfig.deviceToken
        pushKitDeviceToken = appModel.thisAppConfig.pushKitDeviceToken
        fileProviderDeviceToken = appModel.thisAppConfig.fileProviderDeviceToken
    }
    
    func refreshTestMode() {
        guard appModel.thisAppConfig.isValidForSave.valid
        else { return }
        isInTestMode = (config == appModel.thisAppConfig)
    }
}

struct AppContent_Previews: PreviewProvider {
    static var previews: some View {
        AppContent()
            .environmentObject(AppModel())
    }
}
