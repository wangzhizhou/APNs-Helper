//
//  AppContentMacOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI

struct AppContentMacOS: View {

    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var contentModel: AppContentModel

    let loadPayloadTemplate: () -> Void
    let saveAsPreset: () -> Void
    let clearAllPreset: () -> Void
    let clearCurrentConfigPresetIfExist: () -> Void
    let importAppInfoOnPasteboard: () -> Void
    let refreshTestMode: () -> Void

    var body: some View {

        VStack {
            // Preset
            if !appModel.presets.isEmpty {
                HStack {
                    PresetPicker(
                        presets: appModel.presets,
                        selectedPreset: $contentModel.presetConfig) { preset in
                            contentModel.appInfo = preset
                        }
                    Button(Constants.clearallpreset.value, action: clearAllPreset).buttonStyle(BorderedButtonStyle())
                }
            }

            // Push Type & APN Server
            HStack {
                Picker(Constants.pushtype.value, selection: $contentModel.appInfo.pushType) {
                    ForEach(PushType.allCases.filter {
                        !contentModel.isInTestMode || ($0 != .voip && $0 != .fileprovider)
                    }, id: \.self) {
                        Text($0.rawValue)
                            .tag($0)
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

            // App Info
            VStack {

                let titleWidth: CGFloat = 60

                InputView(
                    title: Constants.keyid.value,
                    titleWidth: titleWidth,
                    inputValue: $contentModel.appInfo.keyIdentifier)
                .onChange(of: contentModel.appInfo.keyIdentifier) { _ in
                    refreshTestMode()
                }

                InputView(
                    title: Constants.teamid.value,
                    titleWidth: titleWidth,
                    inputValue: $contentModel.appInfo.teamIdentifier)
                .onChange(of: contentModel.appInfo.teamIdentifier) { _ in
                    refreshTestMode()
                }

                InputView(
                    title: Constants.bundleid.value,
                    titleWidth: titleWidth,
                    inputValue: $contentModel.appInfo.appBundleID)
                .onChange(of: contentModel.appInfo.appBundleID) { _ in
                    refreshTestMode()
                }

                P8KeyView(
                    showFileImporter: $contentModel.showFileImporter,
                    privateKey: $contentModel.appInfo.privateKey,
                    onPrivateKeyChange: { _ in
                        refreshTestMode()
                    },
                    onFileImporterError: { error in
                        appModel.appLog.append(error.localizedDescription)
                    })

                // Token
                TokenView(
                    pushType: contentModel.appInfo.pushType,
                    deviceToken: $contentModel.appInfo.deviceToken,
                    pushKitDeviceToken: $contentModel.appInfo.pushKitVoIPToken,
                    fileProviderDeviceToken: $contentModel.appInfo.pushKitFileProviderToken
                )
                .padding(.vertical, 10)

                HStack {
                    Button(Constants.clearIfExist.value) {
                        clearCurrentConfigPresetIfExist()
                    }
                    Spacer()
#if DEBUG
                    Button(Constants.importAppInfoOnPasteboard.value, action: importAppInfoOnPasteboard)
                    Toggle(isOn: $contentModel.isInTestMode) {
                        Text(Constants.fillInAppInfo.value)
                    }
                    .onChange(of: contentModel.isInTestMode) { mode in
                        if mode {
                            contentModel.appInfo = appModel.thisAppConfig
                        } else {
                            contentModel.clearAppInfo()
                        }
                    }
                    .onChange(of: appModel.thisAppConfig) { _ in
                        guard contentModel.isInTestMode else {
                            return
                        }
                        contentModel.appInfo = appModel.thisAppConfig
                    }
#endif
                    Button(Constants.saveAsPreset.value) {
                        saveAsPreset()
                    }
                }
                .padding(.bottom, 10)
            }

            // Payload
            PayloadEditor(
                title: Constants.payload.value,
                payload: $contentModel.payload
            )
            .frame(height: 200)

            // Send Button Area
            SendButtonArea(loadPayloadTemplate: loadPayloadTemplate)

            // Log
            LogView()

        }
        .frame(minWidth: 600)
        .padding()
    }
}
