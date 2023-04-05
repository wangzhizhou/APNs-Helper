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
                    Picker("Preset", selection: $presetConfig) {
                        ForEach(appModel.presets) {
                            if $0 == .invalid {
                                Text("none").tag($0)
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
                }
                
                HStack {
                    Picker("Push Type", selection: $pushType) {
                        ForEach(PushType.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .onChange(of: pushType, perform: { _ in
                        loadPayloadTemplate()
                    })
                    
                    Spacer(minLength: 50)
                    Picker("APN Server", selection: $apnsServerEnv) {
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
                        
                        InputView(title: "BundleID", inputValue: $appBundleID)
                        
                    } else {
                        
                        InputView(title: "KeyID", inputValue: $keyIdentifier)
                        
                        InputView(title: "TeamID", inputValue: $teamIdentifier)
                        
                        InputView(title: "BundleID", inputValue: $appBundleID)
                        
                        if pushType == .alert || pushType == .background {
                            InputView(title: "Device Token", inputValue: $deviceToken)
                        }
                        
                        if pushType == .voip {
                            InputView(title: "PushKit Device Token", inputValue: $pushKitDeviceToken)
                        }
                        
                        //                        if pushType == .fileprovider {
                        //                            InputView(title: "File Provider Device Token", inputValue: $fileProviderDeviceToken)
                        //                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            HStack{
                                Text("Private Key")
                                Spacer()
                                Button {
                                    showFileImporter = true
                                } label: {
                                    Text("import .p8 file")
                                }
                            }
                            
                            InputTextEditor(content: $privateKey)
                                .frame(height: 50)
                        }
                    }
                }
            }
            
            
            InputTextEditor(title: "Payload", content: $payload, textEditorFont: .body)
                .frame(minHeight: 200)
            
            HStack {
                
                if payload.isEmpty {
                    Button("Load Template (⌘+T)") {
                        loadPayloadTemplate()
                    }
                    .disabled(isLoading)
                    .keyboardShortcut(.init(unicodeScalarLiteral: "T"), modifiers: [.command])
                }
                
                Button {
                    let config = config
                    Task {
                        isLoading = true
                        appModel.resetLog()
                        if payload.isEmpty,  let payloadData = APNsService.templatePayload(for: config)?.data(using: .utf8){
                            try? await APNsService(config: config, payloadData: payloadData).send()
                        }
                        else if let payloadData = payload.data(using: .utf8) {
                            try? await APNsService(config: config, payloadData: payloadData).send()
                        }
                        isLoading = false
                    }
                } label: {
                    Text("Send\(isLoading ? "ing..." : " (⌘+⏎)")")
                }
                .disabled(isLoading)
                .keyboardShortcut(.return, modifiers: [.command])
                
                
                if !AppSandbox.isSandbox() {
                    Toggle(isOn: $simulator) {
                        Text("发送到模拟器")
                    }
                }
            }
            
            Divider()
            
            InputTextEditor(title: "Log", content: $appModel.appLog)
                .frame(minHeight: 100)
            
        }
        .frame(minWidth: 600)
        .padding()
        .onAppear {
            loadPayloadTemplate()
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
