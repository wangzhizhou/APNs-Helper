//
//  AppContent+iOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI
import UniformTypeIdentifiers

extension AppContent {

    var body: some View {
        VStack {
            Form {
                if !appModel.presets.isEmpty {
                    Section("Preset Config") {
                        VStack {
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
                            HStack {
                                Button("Clear All Preset") {
                                    clearAllPreset()
                                }
                                .buttonStyle(BorderedButtonStyle())
                                Spacer()
                            }
                        }
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
                    
                    InputView(title: "TeamID", inputValue: $teamIdentifier)
                    
                    InputView(title: "BundleID", inputValue: $appBundleID)
                    
                    if pushType == .alert || pushType == .background {
                        InputView(title: "Device Token", inputValue: $deviceToken)
                    }
                    
                    if pushType == .voip {
                        InputView(title: "PushKit Device Token", inputValue: $pushKitDeviceToken)
                    }
                    
//                    if pushType == .fileprovider {
//                        InputView(title: "File Provider Device Token", inputValue: $fileProviderDeviceToken)
//                    }
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
                        HStack {
                            Button("Clear If Exist") {
                                clearCurrentConfigPresetIfExist()
                            }
                            Spacer()
                            Button("Save As Preset") {
                                saveAsPreset()
                            }
                        }
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
                
                Section("Payload") {
                    VStack {
                        HStack {
                            Spacer()
                            Button("Load Template") {
                                loadPayloadTemplate()
                            }
                            Button("Clear Payload") {
                                payload = ""
                            }
                            
                        }
                        .buttonStyle(BorderedButtonStyle())
                        InputTextEditor(content: $payload, textEditorFont: .body)
                            .frame(minHeight: 200)
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            
            Button {
                isPresented = true
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
            }
            .padding(.horizontal)
            .padding([.bottom], 8)
            .disabled(isLoading)
            .buttonStyle(BorderedButtonStyle())
        }
        .onAppear {
            loadPayloadTemplate()
        }
        .sheet(isPresented: $isPresented) {
            VStack {
                InputTextEditor(title: "Log", content: $appModel.appLog)
            }
            .padding()
        }
        .alert(isPresented: $appModel.showAlert) {
            Alert(title: Text(appModel.alertMessage ?? ""))
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
