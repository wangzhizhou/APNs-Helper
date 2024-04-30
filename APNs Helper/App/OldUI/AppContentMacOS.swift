//
//  AppContentMacOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI
import SwiftData
import SwiftUIX

struct AppContentMacOS: View {

    @Environment(AppModel.self) private var appModel
    @Environment(AppContentModel.self) private var contentModel
    
    @Query(sort: [.init(\Config.appBundleID)]) private var presets: [Config]

    let loadPayloadTemplate: () -> Void
    let saveAsPreset: () -> Void
    let clearAllPreset: () -> Void
    let clearCurrentConfigPresetIfExist: () -> Void
    let importAppInfoOnPasteboard: () -> Void
    let refreshTestMode: () -> Void

    var body: some View {
        @Bindable var contentModel = contentModel
        VStack {
            // Preset
            if !presets.isEmpty {
                HStack {
                    PresetPicker(
                        presets: presets,
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
                .onChange(of: contentModel.appInfo.pushType, loadPayloadTemplate)
                
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
                .onChange(of: contentModel.appInfo.keyIdentifier, refreshTestMode)

                InputView(
                    title: Constants.teamid.value,
                    titleWidth: titleWidth,
                    inputValue: $contentModel.appInfo.teamIdentifier)
                .onChange(of: contentModel.appInfo.teamIdentifier, refreshTestMode)

                InputView(
                    title: Constants.bundleid.value,
                    titleWidth: titleWidth,
                    inputValue: $contentModel.appInfo.appBundleID)
                .onChange(of: contentModel.appInfo.appBundleID, refreshTestMode)

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
                    fileProviderDeviceToken: $contentModel.appInfo.pushKitFileProviderToken,
                    locationPushServiceToken: $contentModel.appInfo.locationPushServiceToken,
                    liveActivityPushToken: $contentModel.appInfo.liveActivityPushToken
                )
                .padding(.vertical, 10)

                HStack {
                    
                    FeedBackButton(email: Constants.feedbackEmail.value)
                        .frame(width: 30)
                        .tint(.teal)
                        .buttonStyle(BorderedProminentButtonStyle())

                    Spacer()

                    Button(Constants.clearIfExist.value) {
                        clearCurrentConfigPresetIfExist()
                    }
#if DEBUG
                    Button(Constants.importAppInfoOnPasteboard.value, action: importAppInfoOnPasteboard)
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
