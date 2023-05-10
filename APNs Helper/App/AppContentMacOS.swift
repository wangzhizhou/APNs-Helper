//
//  AppContentMacOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI

struct AppContentMacOS: View {
    
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var contentModel: AppContentModel
    
    let loadPayloadTemplate: () -> Void
    let saveAsPreset: () -> Void
    let clearAllPreset: () -> Void
    let clearCurrentConfigPresetIfExist: () -> Void
    
    var body: some View {
        
        VStack {
            // Preset
            if !appModel.presets.isEmpty {
                HStack {
                    PresetPicker(
                        presets: appModel.presets,
                        selectedPreset: $contentModel.presetConfig) { preset in
                            contentModel.appInfo = preset
                        }
                    Button(Constants.clearallpreset.value, action: clearAllPreset).buttonStyle(BorderedButtonStyle())
                }
            }
            
            // Push Type & APN Server
            HStack {
                Picker(Constants.pushtype.value, selection: $contentModel.appInfo.pushType) {
                    ForEach(PushType.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .onChange(of: contentModel.appInfo.pushType, perform: { _ in
                    loadPayloadTemplate()
                })
                Spacer(minLength: 50)
                Picker(Constants.apnserver.value, selection: $contentModel.appInfo.apnsServerEnv) {
                    ForEach(APNServerEnv.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.bottom)
            
            // App Info
            GroupBox {
                
                VStack(alignment: .trailing) {
                    
                    InputView(
                        title: Constants.keyid.value,
                        inputValue: $contentModel.appInfo.keyIdentifier)
                    
                    InputView(
                        title: Constants.teamid.value,
                        inputValue: $contentModel.appInfo.teamIdentifier)
                    
                    InputView(
                        title: Constants.bundleid.value,
                        inputValue: $contentModel.appInfo.appBundleID)
                    
                    P8KeyView(
                        showFileImporter: $contentModel.showFileImporter,
                        privateKey: $contentModel.appInfo.privateKey,
                        onPrivateKeyChange: nil,
                        onFileImporterError: { error in
                            appModel.appLog.append(error.localizedDescription)
                        })
                    
                    // Token
                    Group {
                        TokenView(
                            pushType: contentModel.appInfo.pushType,
                            deviceToken: $contentModel.appInfo.deviceToken,
                            pushKitDeviceToken: $contentModel.appInfo.pushKitDeviceToken)
                    }
                    .padding(.vertical)
                    
                    HStack {
                        Button(Constants.clearIfExist.value) {
                            clearCurrentConfigPresetIfExist()
                        }
                        Spacer()
                        Button(Constants.saveAsPreset.value) {
                            saveAsPreset()
                        }
                    }
                }
            }
            
            // Payload
            InputTextEditor(
                title: Constants.payload.value,
                content: $contentModel.payload,
                textEditorFont: .body)
            .frame(minHeight: 200)
            
            // Send Button Area
            SendButtonArea(loadPayloadTemplate: loadPayloadTemplate)
            
            Divider()
            
            // Log
            LogView()
            
        }
        .frame(minWidth: 600)
        .padding()
    }
}
