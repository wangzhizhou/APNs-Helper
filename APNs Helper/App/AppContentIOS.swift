//
//  AppContentIOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI
import UniformTypeIdentifiers
import AlertToast

struct AppContentIOS: View {
    
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var contentModel: AppContentModel
    
    let loadPayloadTemplate: () -> Void
    let saveAsPreset: () -> Void
    let clearAllPreset: () -> Void
    let clearCurrentConfigPresetIfExist: () -> Void
    let refreshTestMode: () -> Void
    
    @FocusState
    private var logTextEditorFocusState: Bool
    
    var body: some View {
        VStack {
            Form {
                if !appModel.presets.isEmpty {
                    Picker(Constants.preset.value, selection: $contentModel.presetConfig) {
                        ForEach(appModel.presets) {
                            if $0 == .none {
                                Text(Constants.presetnone.value).tag($0)
                            } else {
                                Text($0.appBundleID)
                                    .lineLimit(1)
                                    .tag($0)
                            }
                        }
                    }
                    .pickerStyle(.inline)
                    .onChange(of: contentModel.presetConfig) { preset in
                        contentModel.appInfo = preset
                    }
                    Button(Constants.clearallpreset.value) {
                        clearAllPreset()
                    }
                }
                
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
                
                Section(Constants.appInfo.value) {
                    
                    InputView(title: Constants.keyid.value, inputValue: $contentModel.appInfo.keyIdentifier)
                        .onChange(of: contentModel.appInfo.keyIdentifier) { _ in
                            refreshTestMode()
                        }
                    
                    InputView(title: Constants.teamid.value, inputValue: $contentModel.appInfo.teamIdentifier)
                        .onChange(of: contentModel.appInfo.teamIdentifier) { _ in
                            refreshTestMode()
                        }
                    
                    InputView(title: Constants.bundleid.value, inputValue: $contentModel.appInfo.appBundleID)
                        .onChange(of: contentModel.appInfo.appBundleID) { _ in
                            refreshTestMode()
                        }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(Constants.p8key.value)
                            Spacer()
                            Button {
                                contentModel.showFileImporter = true
                            } label: {
                                Text(Constants.importP8File.value)
                            }
                        }
                        InputTextEditor(content: $contentModel.appInfo.privateKey)
                            .frame(height: 80)
                            .onChange(of: contentModel.appInfo.privateKey) { _ in
                                refreshTestMode()
                            }
                    }
                    
                    if contentModel.appInfo.pushType == .alert || contentModel.appInfo.pushType == .background {
                        InputView(title: Constants.devicetoken.value, inputValue: $contentModel.appInfo.deviceToken)
                    } else if contentModel.appInfo.pushType == .voip {
                        InputView(title: Constants.pushkittoken.value, inputValue: $contentModel.appInfo.pushKitDeviceToken)
                    }
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
                
                Section(Constants.payload.value) {
                    InputTextEditor(content: $contentModel.payload, textEditorFont: .body)
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
                    VStack {
                        InputTextEditor(content: $appModel.appLog, textEditorFont: .system(size: 9))
                            .focused($logTextEditorFocusState)
                            .onChange(of: logTextEditorFocusState, perform: { focusState in
                                guard focusState == false
                                else {
                                    logTextEditorFocusState = false
                                    return
                                }
                            })
                            .frame(height: 100)
                            .padding(.vertical, 5)
                        
                        Button {
                            
                            guard contentModel.config.isReadyForSend else {
                                appModel.alertMessage = Constants.tipForNotReady.value
                                return
                            }
                            
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
                            GeometryReader { geometry in
                                HStack {
                                    if appModel.isSendingPush {
                                        ProgressView()
                                            .tint(Color.orange)
                                            .padding([.trailing], 1)
                                    }
                                    Text(appModel.isSendingPush ? Constants.sending.value : Constants.sendPush.value)
                                        .bold()
                                        .font(.title3)
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height)
                            }
                        }
                        .frame(height: 60)
                        .buttonStyle(BorderedProminentButtonStyle())
                        .disabled(appModel.isSendingPush)
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .toast(isPresenting: $appModel.showToast) {
            AlertToast(displayMode: .hud, type: .regular, title: appModel.toastMessage)
        }
    }
}
