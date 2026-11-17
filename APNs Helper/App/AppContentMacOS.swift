//
//  AppContentMacOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI

struct AppContentMacOS: View {

    @Environment(AppModel.self) private var appModel
    @Environment(AppContentModel.self) private var contentModel

    @Environment(\.appActions) private var actions

    var body: some View {
        @Bindable var contentModel = contentModel


        VStack {
            // Preset
            if !appModel.presets.isEmpty {
                HStack {
                    PresetPicker(
                        presets: appModel.presets,
                        selectedPreset: $contentModel.presetConfig) { preset in
                            contentModel.appInfo = preset
                        }
                    Button(Constants.clearallpreset.value, action: { actions.clearAllPreset() }).buttonStyle(BorderedButtonStyle())
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
                .onChange(of: contentModel.appInfo.pushType, { actions.loadPayloadTemplate() })
                
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
                .onChange(of: contentModel.appInfo.keyIdentifier, { actions.refreshTestMode() })

                InputView(
                    title: Constants.teamid.value,
                    titleWidth: titleWidth,
                    inputValue: $contentModel.appInfo.teamIdentifier)
                .onChange(of: contentModel.appInfo.teamIdentifier, { actions.refreshTestMode() })

                InputView(
                    title: Constants.bundleid.value,
                    titleWidth: titleWidth,
                    inputValue: $contentModel.appInfo.appBundleID)
                .onChange(of: contentModel.appInfo.appBundleID, { actions.refreshTestMode() })

                P8KeyView(
                    showFileImporter: $contentModel.showFileImporter,
                    privateKey: $contentModel.appInfo.privateKey,
                    onPrivateKeyChange: { _ in
                        actions.refreshTestMode()
                    },
                    onFileImporterError: { error in
                        appModel.appLog.append(error.localizedDescription)
                    })

                // Token
                TokenView(
                    pushType: contentModel.appInfo.pushType,
                    deviceToken: $contentModel.appInfo.deviceToken,
                    pushKitDeviceToken: $contentModel.appInfo.pushKitVoIPToken,
                    fileProviderDeviceToken: $contentModel.appInfo.pushKitFileProviderToken,
                    locationPushServiceToken: $contentModel.appInfo.locationPushServiceToken,
                    liveActivityPushToken: $contentModel.appInfo.liveActivityPushToken
                )
                .padding(.vertical, 10)

                HStack {
                    Button(Constants.clearIfExist.value) {
                        actions.clearCurrentConfigPresetIfExist()
                    }
                    Spacer()
#if DEBUG
                    Button(Constants.importAppInfoOnPasteboard.value, action: { actions.importAppInfoOnPasteboard() })
                    Toggle(isOn: $contentModel.isInTestMode) {
                        Text(Constants.fillInAppInfo.value)
                    }
                    .onChange(of: contentModel.isInTestMode) { _, newValue in
                        if newValue {
                            contentModel.appInfo = appModel.thisAppConfig
                        } else {
                            contentModel.clearAppInfo()
                        }
                    }
                    .onChange(of: appModel.thisAppConfig) {
                        guard contentModel.isInTestMode else {
                            return
                        }
                        contentModel.appInfo = appModel.thisAppConfig
                    }
#endif
                    Button(Constants.saveAsPreset.value) {
                        actions.saveAsPreset()
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
            SendButtonArea(loadPayloadTemplate: actions.loadPayloadTemplate)

            // Log
            LogView()

        }
        .frame(minWidth: 600)
        .padding()
    }
}
