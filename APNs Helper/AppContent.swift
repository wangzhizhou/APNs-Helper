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
    @State var log: String = ""
    
    var body: some View {
        
        VStack {
            
            Picker("预设配置", selection: $presetConfig) {
                Text("custom").tag(Config.invalid)
                Text(Config.f100.appBundleID).tag(Config.f100)
                Text(Config.f100InHouse.appBundleID).tag(Config.f100InHouse)
                Text(Config.f101.appBundleID).tag(Config.f101)
                Text(Config.f101InHouse.appBundleID).tag(Config.f101InHouse)
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
            
            GroupBox {
                VStack(alignment: .trailing) {
                    
                    InputView(title: "KeyID", inputValue: $keyIdentifier)
                    
                    InputView(title: "TeamID", inputValue: $teamIdentifier)
                    
                    InputView(title: "BundleID", inputValue: $appBundleID)
                    
                    InputView(title: "Device Token", inputValue: $deviceToken)
                    
                    InputView(title: "PushKit Device Token", inputValue: $pushKitDeviceToken)
                    
                    InputView(title: "File Provider Device Token", inputValue: $fileProviderDeviceToken)
                    
                    VStack(alignment: .leading) {
                        HStack{
                            Text("Private Key")
                            Spacer()
                            Button {
                                let (output, error) = APNsService.chooseP8AndDecrypt()
                                if let output = output {
                                    privateKey = output
                                }
                                if let error = error {
                                    log.append(error)
                                }
                            } label: {
                                Text("import .p8 file")
                            }
                        }
                        
                        InputTextEditor(content: $privateKey)
                            .frame(height: 80)
                    }
                }
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
            
            Divider()
            
            InputTextEditor(title: "Payload", content: $payload)
                .frame(height: 200)
            
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
                    try? await APNsService(config: config).send()
                }
            } label: {
                Text("发送")
            }
            
            Divider()
            
            InputTextEditor(title: "Log", content: $log)
                .disabled(true)
                .frame(height: 100)
        }
        .frame(width: 600)
        .padding()
    }
}

struct AppContent_Previews: PreviewProvider {
    static var previews: some View {
        AppContent()
    }
}
