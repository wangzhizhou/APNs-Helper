//
//  AppContentMacOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI
import UniformTypeIdentifiers

struct AppContentMacOS: View {
    
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var contentModel: AppContentModel
    
    let loadPayloadTemplate: () -> Void
    let saveAsPreset: () -> Void
    let clearAllPreset: () -> Void
    let clearCurrentConfigPresetIfExist: () -> Void
    
    var body: some View {
        
        VStack {
            
            if !contentModel.simulator {
                
                if !appModel.presets.isEmpty {
                    HStack {
                        Picker(Constants.preset.value, selection: $contentModel.presetConfig) {
                            ForEach(appModel.presets) {
                                if $0 == .none {
                                    Text(Constants.presetnone.value).tag($0)
                                } else {
                                    Text($0.appBundleID).tag($0)
                                }
                            }
                        }
                        .padding(.vertical)
                        .onChange(of: contentModel.presetConfig) { preset in
                            contentModel.appInfo = preset
                        }
                        Button(Constants.clearallpreset.value) {
                            clearAllPreset()
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                }
                
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
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.bottom)
            }
            
            GroupBox {
                
                VStack(alignment: .trailing) {
                    
                    if contentModel.simulator {
                        
                        InputView(title: Constants.bundleid.value, inputValue: $contentModel.appInfo.appBundleID)
                        
                    } else {
                        
                        InputView(title: Constants.keyid.value, inputValue: $contentModel.appInfo.keyIdentifier)
                        
                        InputView(title: Constants.teamid.value, inputValue: $contentModel.appInfo.teamIdentifier)
                        
                        InputView(title: Constants.bundleid.value, inputValue: $contentModel.appInfo.appBundleID)
                        
                        VStack(alignment: .leading) {
                            HStack{
                                Text(Constants.p8key.value)
                                Spacer()
                                Button {
                                    contentModel.showFileImporter = true
                                } label: {
                                    Text(Constants.importP8File.value)
                                }
                            }
                            
                            InputTextEditor(content: $contentModel.appInfo.privateKey)
                                .frame(height: 50)
                            
                        }
                        
                        Group {
                            
                            if contentModel.appInfo.pushType == .alert || contentModel.appInfo.pushType == .background {
                                InputView(title: Constants.devicetoken.value, inputValue: $contentModel.appInfo.deviceToken)
                            }
                            
                            if contentModel.appInfo.pushType == .voip {
                                InputView(title: Constants.pushkittoken.value, inputValue: $contentModel.appInfo.pushKitDeviceToken)
                            }
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
            }
            
            
            InputTextEditor(title: Constants.payload.value, content: $contentModel.payload, textEditorFont: .body)
                .frame(minHeight: 200)
            
            HStack {
                
                if contentModel.payload.isEmpty {
                    Button(Constants.loadTemplate.value) {
                        loadPayloadTemplate()
                    }
                    .disabled(appModel.isSendingPush)
                    .keyboardShortcut(.init(unicodeScalarLiteral: Constants.loadTemplateShortcutKey.firstChar), modifiers: [.command])
                }
                
                Button {
                    let config = contentModel.config
                    Task {
                        appModel.isSendingPush = true
                        appModel.resetLog()
                        if contentModel.payload.isEmpty,  let payloadData = APNsService.templatePayload(for: config)?.data(using: .utf8){
                            try? await APNsService(config: config, payloadData: payloadData, appModel: appModel).send()
                        }
                        else if let payloadData = contentModel.payload.data(using: .utf8) {
                            try? await APNsService(config: config, payloadData: payloadData, appModel: appModel).send()
                        }
                        appModel.isSendingPush = false
                    }
                } label: {
                    Text(appModel.isSendingPush ? Constants.sending.value : Constants.send.value)
                }
                .disabled(appModel.isSendingPush)
                .keyboardShortcut(.return, modifiers: [.command])
                
                
                if !AppSandbox.isSandbox() {
                    Toggle(isOn: $contentModel.simulator) {
                        Text(Constants.sendToSimulator.value)
                    }
                }
            }
            
            Divider()
            
            InputTextEditor(title: Constants.log.value, content: $appModel.appLog)
                .frame(minHeight: 100)
            
        }
        .frame(minWidth: 600)
        .padding()
    }
}
