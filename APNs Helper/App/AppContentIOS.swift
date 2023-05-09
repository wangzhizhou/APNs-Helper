//
//  AppContentIOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI

struct AppContentIOS: View {
    
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var contentModel: AppContentModel
    
    let loadPayloadTemplate: () -> Void
    let saveAsPreset: () -> Void
    let clearAllPreset: () -> Void
    let clearCurrentConfigPresetIfExist: () -> Void
    
    let refreshTestMode: () -> Void
    
    var body: some View {
        Form {
            // Preset
            if !appModel.presets.isEmpty {
                PresetPicker(presets: appModel.presets, selectedPreset: $contentModel.presetConfig) { preset in
                    contentModel.appInfo = preset
                }
                Button(Constants.clearallpreset.value, action: clearAllPreset)
            }
            
            // Push Type & APN Server
            Section(Constants.apnserver.value) {
                Picker(Constants.pushtype.value, selection: $contentModel.appInfo.pushType) {
                    ForEach(PushType.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .onChange(of: contentModel.appInfo.pushType, perform: { _ in
                    loadPayloadTemplate()
                })
                Picker(Constants.apnserver.value, selection: $contentModel.appInfo.apnsServerEnv) {
                    ForEach(APNServerEnv.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
            }
            
            // App Info
            Section(Constants.appInfo.value) {
                
                InputView(
                    title: Constants.keyid.value,
                    inputValue: $contentModel.appInfo.keyIdentifier)
                .onChange(of: contentModel.appInfo.keyIdentifier) { _ in
                    refreshTestMode()
                }
                
                InputView(
                    title: Constants.teamid.value,
                    inputValue: $contentModel.appInfo.teamIdentifier)
                .onChange(of: contentModel.appInfo.teamIdentifier) { _ in
                    refreshTestMode()
                }
                
                InputView(
                    title: Constants.bundleid.value,
                    inputValue: $contentModel.appInfo.appBundleID)
                .onChange(of: contentModel.appInfo.appBundleID) { _ in
                    refreshTestMode()
                }
                
                P8KeyView(
                    showFileImporter: $contentModel.showFileImporter,
                    privateKey: $contentModel.appInfo.privateKey) { _ in
                        refreshTestMode()
                    } onFileImporterError: { error in
                        appModel.appLog.append(error.localizedDescription)
                    }
                
                // Token
                TokenView(
                    pushType: contentModel.appInfo.pushType,
                    deviceToken: $contentModel.appInfo.deviceToken,
                    pushKitDeviceToken: $contentModel.appInfo.pushKitDeviceToken)
            }
            
#if DEBUG
            Toggle(isOn: $contentModel.isInTestMode) {
                Text(Constants.fillInAppInfo.value)
            }
            .onChange(of: contentModel.isInTestMode) { mode in
                if mode {
                    contentModel.appInfo = appModel.thisAppConfig
                }
            }
            .onChange(of: appModel.thisAppConfig) { _ in
                guard contentModel.isInTestMode else {
                    return
                }
                contentModel.appInfo = appModel.thisAppConfig
            }
#endif
            
            if !contentModel.config.isEmpty {
                Button(Constants.clearCurrentAppInfo.value) {
                    contentModel.clearAppInfo()
                }
            }
            if !contentModel.appInfo.appBundleID.isEmpty {
                Button(Constants.removeAppInfoFromPreset.value) {
                    clearCurrentConfigPresetIfExist()
                }
            }
            if contentModel.config.isValidForSave.valid {
                Button(Constants.saveAppInfoAsPreset.value) {
                    saveAsPreset()
                }
            }
            
            // Payload
            Section(Constants.payload.value) {
                InputTextEditor(
                    content: $contentModel.payload,
                    textEditorFont: .body)
                .frame(minHeight: 200)
                .padding(.vertical)
            }
            
            Group {
                Button( Constants.loadTemplatePayload.value) {
                    loadPayloadTemplate()
                }
                
                Button(Constants.clearPayload.value) {
                    contentModel.payload = ""
                }
            }
            
            
            Section(Constants.log.value) {
                // Log
                LogView()
                // Send Button Area
                SendButtonArea(loadPayloadTemplate: loadPayloadTemplate)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
}
