//
//  AppContent.swift
//  APNs Helper
//
//  Created by joker on 2022/9/28.
//

import SwiftUI

struct AppContent: View {
    
    @EnvironmentObject var appModel: AppModel
    
    @State var presetConfig: Config = .invalid
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
    @State var isLoading: Bool = false
    
    @State var simulator: Bool = false
    
    var config: Config {
        .init(
            deviceToken: deviceToken.trimmingCharacters(in: .whitespacesAndNewlines),
            pushKitDeviceToken: pushKitDeviceToken.trimmingCharacters(in: .whitespacesAndNewlines),
            fileProviderDeviceToken: fileProviderDeviceToken.trimmingCharacters(in: .whitespacesAndNewlines),
            appBundleID: appBundleID.trimmingCharacters(in: .whitespacesAndNewlines),
            privateKey: privateKey,
            keyIdentifier: keyIdentifier.trimmingCharacters(in: .whitespacesAndNewlines),
            teamIdentifier: teamIdentifier.trimmingCharacters(in: .whitespacesAndNewlines),
            pushType:pushType,
            apnsServerEnv: apnsServerEnv,
            sendToSimulator: simulator
        )
    }
    
    var body: some View {
        
        VStack {
            
            if !simulator {
                
                if !appModel.presets.isEmpty {
                    Picker("Preset", selection: $presetConfig) {
                        ForEach(appModel.presets) {
                            if $0 == .invalid {
                                Text("custom").tag($0)
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
                        
                        if pushType == .fileprovider {
                            InputView(title: "File Provider Device Token", inputValue: $fileProviderDeviceToken)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            HStack{
                                Text("Private Key")
                                Spacer()
                                Button {
                                    let (output, error) = Finder.chooseP8AndDecrypt()
                                    if let output = output {
                                        privateKey = output
                                    }
                                    if let error = error {
                                        appModel.appLog.append(error)
                                    }
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
                
                Toggle(isOn: $simulator) {
                    Text("发送到模拟器")
                }
            }
            
            Divider()
            
            InputTextEditor(title: "Log", content: $appModel.appLog)
                .frame(minHeight: 100, maxHeight: 200)
            
        }
        .frame(minWidth: 600)
        .padding()
        .onAppear {
            loadPayloadTemplate()
        }
    }
    
    
    func loadPayloadTemplate() {
        if let template = APNsService.templatePayload(for: config) {
            payload = template
        }
    }
}

struct AppContent_Previews: PreviewProvider {
    static var previews: some View {
        AppContent()
            .environmentObject(AppModel())
    }
}
