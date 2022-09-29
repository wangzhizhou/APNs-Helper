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
    
    var body: some View {
        
        VStack {
            
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
                .onChange(of: presetConfig, perform: { tag in
                    teamIdentifier = tag.teamIdentifier
                    keyIdentifier = tag.keyIdentifier
                    appBundleID = tag.appBundleID
                    deviceToken = tag.deviceToken
                    pushKitDeviceToken = tag.pushKitDeviceToken
                    fileProviderDeviceToken = tag.fileProviderDeviceToken
                    privateKey = tag.privateKey
                })
            }
            
            HStack {
                Picker("Push Type", selection: $pushType) {
                    ForEach(PushType.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                
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
            
            GroupBox {
                VStack(alignment: .trailing) {
                    
                    InputView(title: "KeyID", inputValue: $keyIdentifier)
                    
                    InputView(title: "TeamID", inputValue: $teamIdentifier)
                    
                    InputView(title: "BundleID", inputValue: $appBundleID)
                    
                    InputView(title: "Device Token", inputValue: $deviceToken)
                    
                    InputView(title: "PushKit Device Token", inputValue: $pushKitDeviceToken)
                    
                    InputView(title: "File Provider Device Token", inputValue: $fileProviderDeviceToken)
                    
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
            
            
            InputTextEditor(title: "Payload \(payload.isEmpty ? "(no payload will send preset test data)" : "")", content: $payload)
                .frame(height: 200)
            
            HStack {
                Button {
                    let config = Config(
                        deviceToken: deviceToken.trimmingCharacters(in: .whitespacesAndNewlines),
                        pushKitDeviceToken: pushKitDeviceToken.trimmingCharacters(in: .whitespacesAndNewlines),
                        fileProviderDeviceToken: fileProviderDeviceToken.trimmingCharacters(in: .whitespacesAndNewlines),
                        appBundleID: appBundleID.trimmingCharacters(in: .whitespacesAndNewlines),
                        privateKey: privateKey,
                        keyIdentifier: keyIdentifier.trimmingCharacters(in: .whitespacesAndNewlines),
                        teamIdentifier: teamIdentifier.trimmingCharacters(in: .whitespacesAndNewlines),
                        pushType:pushType,
                        apnsServerEnv: apnsServerEnv)
                    
                    Task {
                        isLoading = true
                        appModel.resetLog()
                        let payloadData = !payload.isEmpty ? payload.data(using: .utf8) : nil
                        try? await APNsService(config: config, payloadData: payloadData).send()
                        isLoading = false
                    }
                } label: {
                    Text("Send\(isLoading ? "ing..." : "(⌘+⏎)")")
                }
                .disabled(isLoading)
                .keyboardShortcut(.return, modifiers: [.command])
            }
            
            Divider()
            
            InputTextEditor(title: "Log", content: $appModel.appLog)
                .frame(height: 100)
        }
        .frame(width: 700)
        .padding()
    }
}

struct AppContent_Previews: PreviewProvider {
    static var previews: some View {
        AppContent()
    }
}
