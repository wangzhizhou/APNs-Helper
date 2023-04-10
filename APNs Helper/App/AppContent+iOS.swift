//
//  AppContent+iOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI
import UniformTypeIdentifiers
import AlertToast

extension AppContent {
    
    var body: some View {
        VStack {
            Form {
                if !appModel.presets.isEmpty {
                    Picker("Preset Config", selection: $presetConfig) {
                        ForEach(appModel.presets) {
                            if $0 == .none {
                                Text("none").tag($0)
                            } else {
                                Text($0.appBundleID)
                                    .lineLimit(1)
                                    .tag($0)
                            }
                        }
                    }
                    .pickerStyle(.inline)
                    .onChange(of: presetConfig) { tag in
                        teamIdentifier = tag.teamIdentifier
                        keyIdentifier = tag.keyIdentifier
                        appBundleID = tag.appBundleID
                        deviceToken = tag.deviceToken
                        pushKitDeviceToken = tag.pushKitDeviceToken
                        fileProviderDeviceToken = tag.fileProviderDeviceToken
                        privateKey = tag.privateKey
                    }
                    Button("Clear All Preset Config") {
                        clearAllPreset()
                    }
                }
                
                Section("APNs Server Config") {
                    Picker("Push Type", selection: $pushType) {
                        ForEach(PushType.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .onChange(of: pushType, perform: { _ in
                        loadPayloadTemplate()
                    })
                    
                    Picker("APN Server", selection: $apnsServerEnv) {
                        ForEach(APNServerEnv.allCases, id: \.self) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                }
                
                Section("App Info") {
                    
                    InputView(title: "KeyID", inputValue: $keyIdentifier)
                        .onChange(of: keyIdentifier) { _ in
                            refreshTestMode()
                        }
                    
                    InputView(title: "TeamID", inputValue: $teamIdentifier)
                        .onChange(of: teamIdentifier) { _ in
                            refreshTestMode()
                        }
                    
                    InputView(title: "BundleID", inputValue: $appBundleID)
                        .onChange(of: appBundleID) { _ in
                            refreshTestMode()
                        }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("P8 Key")
                            Spacer()
                            Button {
                                showFileImporter = true
                            } label: {
                                Text("import .p8 file")
                            }
                        }
                        InputTextEditor(content: $privateKey)
                            .frame(height: 80)
                            .onChange(of: privateKey) { _ in
                                refreshTestMode()
                            }
                    }
                    
                    if pushType == .alert || pushType == .background {
                        InputView(title: "Device Token", inputValue: $deviceToken)
                    } else if pushType == .voip {
                        InputView(title: "PushKit Device Token", inputValue: $pushKitDeviceToken)
                    }
                }
                
                Toggle(isOn: $isInTestMode) {
                    Text("Fill this App's Info ")
                }
                .onChange(of: isInTestMode) { mode in
                    if mode {
                        configThisAppInfo()
                    }
                }
                .onChange(of: appModel.thisAppConfig) { _ in
                    guard isInTestMode else {
                        return
                    }
                    configThisAppInfo()
                }
                if !config.isEmpty {
                    Button("Clear Current App Info") {
                        clearAppInfo()
                    }
                }
                if !appBundleID.isEmpty {
                    Button("Remove App Info From Preset Config") {
                        clearCurrentConfigPresetIfExist()
                    }
                }
                if config.isValidForSave.valid {
                    Button("Save App Info As Preset Config") {
                        saveAsPreset()
                    }
                }
                
                Section("Payload") {
                    InputTextEditor(content: $payload, textEditorFont: .body)
                        .frame(minHeight: 200)
                        .padding(.vertical)
                }
                
                Group {
                    Button("Load Template Payload") {
                        loadPayloadTemplate()
                    }
                    
                    Button("Clear Payload") {
                        payload = ""
                    }
                }
                
                Section("App Log") {
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
                            guard config.isReadyForSend else {
                                appModel.alertMessage = "The App Info is not ready for send push!"
                                return
                            }
                            let config = config
                            Task {
                                appModel.isSendingPush = true
                                appModel.resetLog()
                                if payload.isEmpty,  let payloadData = APNsService.templatePayload(for: config)?.data(using: .utf8){
                                    try? await APNsService(config: config, payloadData: payloadData).send()
                                }
                                else if let payloadData = payload.data(using: .utf8) {
                                    try? await APNsService(config: config, payloadData: payloadData).send()
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
                                    Text("Send\(appModel.isSendingPush ? "ing..." : " Push")")
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
        .onAppear {
            loadPayloadTemplate()
        }
        .alert(isPresented: $appModel.showAlert) {
            Alert(title: Text(appModel.alertMessage ?? ""))
        }
        .toast(isPresenting: $appModel.showToast) {
            AlertToast(displayMode: .hud, type: .regular, title: appModel.toastMessage)
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [UTType(filenameExtension: "p8")!]) { result in
            switch result {
            case .success(let url):
                if let output = url.p8FileContent {
                    privateKey = output
                }
            case .failure(let error):
                appModel.appLog.append(error.localizedDescription)
            }
        }
    }
}
