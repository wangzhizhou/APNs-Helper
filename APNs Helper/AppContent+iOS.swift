//
//  AppContent+iOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI

extension AppContent {
    
    var body: some View {
        VStack {
            Form {
                Section("Picker Options") {
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
                    if !AppSandbox.isSandbox() {
                        Toggle(isOn: $simulator) {
                            Text("发送到模拟器")
                        }
                    }
                }
                Section("Config Info") {
                    
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
                    VStack(alignment: .leading) {
                        Text("Private Key")
                        InputTextEditor(content: $privateKey)
                            .background(.gray)
                            .frame(height: 80)
                    }
                }
                
                Section("Payload") {
                    InputTextEditor(content: $payload, textEditorFont: .body)
                        .frame(minHeight: 200)
                }
                Section("Log") {
                    InputTextEditor(title: "Log", content: $appModel.appLog)
                        .frame(minHeight: 100)
                }
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
                GeometryReader { geometry in
                    Text("Send\(isLoading ? "ing..." : "")")
                        .bold()
                        .font(.title2)
                        .frame(width: geometry.size.width, height: geometry.size
                            .height)
                }.frame(height: 44)
            }.padding(.horizontal)
            .disabled(isLoading)
            .buttonStyle(BorderedButtonStyle())
            
        }
        .onAppear {
            loadPayloadTemplate()
        }
    }
}
