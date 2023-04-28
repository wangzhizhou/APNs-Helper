//
//  AppContent+macOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI
import UniformTypeIdentifiers

extension AppContent {
    
    var body: some View {
        
        VStack {
            
            if !simulator {
                
                if !appModel.presets.isEmpty {
                    HStack {
                        Picker(Constants.preset.value, selection: $presetConfig) {
                            ForEach(appModel.presets) {
                                if $0 == .none {
                                    Text(Constants.presetnone.value).tag($0)
                                } else {
                                    Text($0.appBundleID).tag($0)
                                }
                            }
                        }
                        .padding(.vertical)
                        .onChange(of: presetConfig) { tag in
                            teamIdentifier = tag.teamIdentifier
                            keyIdentifier = tag.keyIdentifier
                            appBundleID = tag.appBundleID
                            deviceToken = tag.deviceToken
                            pushKitDeviceToken = tag.pushKitDeviceToken
                            fileProviderDeviceToken = tag.fileProviderDeviceToken
                            privateKey = tag.privateKey
                        }
                        Button(Constants.clearallpreset.value) {
                            clearAllPreset()
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                }
                
                HStack {
                    Picker(Constants.pushtype.value, selection: $pushType) {
                        ForEach(PushType.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .onChange(of: pushType, perform: { _ in
                        loadPayloadTemplate()
                    })
                    
                    Spacer(minLength: 50)
                    Picker(Constants.apnserver.value, selection: $apnsServerEnv) {
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
                    
                    if simulator {
                        
                        InputView(title: Constants.bundleid.value, inputValue: $appBundleID)
                        
                    } else {
                        
                        InputView(title: Constants.keyid.value, inputValue: $keyIdentifier)
                        
                        InputView(title: Constants.teamid.value, inputValue: $teamIdentifier)
                        
                        InputView(title: Constants.bundleid.value, inputValue: $appBundleID)
                        
                        VStack(alignment: .leading) {
                            HStack{
                                Text(Constants.p8key.value)
                                Spacer()
                                Button {
                                    showFileImporter = true
                                } label: {
                                    Text(Constants.importP8File.value)
                                }
                            }
                            
                            InputTextEditor(content: $privateKey)
                                .frame(height: 50)
                            
                        }
                        
                        Group {
                            
                            if pushType == .alert || pushType == .background {
                                InputView(title: Constants.devicetoken.value, inputValue: $deviceToken)
                            }
                            
                            if pushType == .voip {
                                InputView(title: Constants.pushkittoken.value, inputValue: $pushKitDeviceToken)
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
            
            
            InputTextEditor(title: Constants.payload.value, content: $payload, textEditorFont: .body)
                .frame(minHeight: 200)
            
            HStack {
                
                if payload.isEmpty {
                    Button(Constants.loadTemplate.value) {
                        loadPayloadTemplate()
                    }
                    .disabled(appModel.isSendingPush)
                    .keyboardShortcut(.init(unicodeScalarLiteral: Constants.loadTemplateShortcutKey.firstChar), modifiers: [.command])
                }
                
                Button {
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
                    Text(appModel.isSendingPush ? Constants.sending.value : Constants.send.value)
                }
                .disabled(appModel.isSendingPush)
                .keyboardShortcut(.return, modifiers: [.command])
                
                
                if !AppSandbox.isSandbox() {
                    Toggle(isOn: $simulator) {
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
        .onAppear {
            loadPayloadTemplate()
        }
        .alert(isPresented: $appModel.showAlert) {
            Alert(title: Text(appModel.alertMessage ?? ""))
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [UTType(filenameExtension: Constants.p8FileExt.value)!]) { result in
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
