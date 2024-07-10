//
//  AppContentIOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI
import SwiftData
import SwiftUIX

struct AppContentIOS: View {

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
            ScrollViewReader { scrollView in
                Form {
                    HStack {
                        Spacer()
                        FeedBackButton(email: Constants.feedbackEmail.value)
                            .tint(.teal)
                        Spacer()
                    }
                    // Preset
                    if !presets.isEmpty {
                        PresetPicker(presets: presets, selectedPreset: $contentModel.presetConfig) { preset in
                            contentModel.appInfo = preset
                        }
                        Button(Constants.clearallpreset.value, action: clearAllPreset)
                    }

                    // Push Type & APN Server
                    Section(Constants.apnserver.value) {
                        Picker(Constants.pushtype.value, selection: $contentModel.appInfo.pushType) {
                            ForEach(APNPushType.allCases.filter {
                                !contentModel.isInTestMode || $0 != .fileprovider
                            }, id: \.self) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .onChange(of: contentModel.appInfo.pushType, loadPayloadTemplate)

                        Picker(Constants.apnserver.value, selection: $contentModel.appInfo.apnsServerEnv) {
                            ForEach(APNServerEnv.allCases, id: \.self) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)

                    // App Info
                    Section(Constants.appInfo.value) {

                        let titleWidth: CGFloat = 70

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
                            editorHeight: 120) { _ in
                                refreshTestMode()
                            } onFileImporterError: { error in
                                appModel.appLog.append(error.localizedDescription)
                            }

                        // Token
                        TokenView(
                            pushType: contentModel.appInfo.pushType,
                            deviceToken: $contentModel.appInfo.deviceToken,
                            pushKitDeviceToken: $contentModel.appInfo.pushKitVoIPToken,
                            fileProviderDeviceToken: $contentModel.appInfo.pushKitFileProviderToken,
                            locationPushServiceToken: $contentModel.appInfo.locationPushServiceToken,
                            liveActivityPushToken: $contentModel.appInfo.liveActivityPushToken
                        )

#if DEBUG
                        Toggle(isOn: $contentModel.isInTestMode) {
                            Text(Constants.fillInAppInfo.value)
                        }
                        .onChange(of: contentModel.isInTestMode) { _, mode in
                            if mode {
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
                        Button(Constants.importAppInfoOnPasteboard.value, action: importAppInfoOnPasteboard)
#endif
                    }
                    .listRowSeparator(.hidden)

                    if !contentModel.config.isEmpty {
                        Button(Constants.clearCurrentAppInfo.value) {
                            contentModel.clearAppInfo()
                        }
                    }
                    if !contentModel.appInfo.appBundleID.isEmpty {
                        Button(Constants.removeAppInfoFromPreset.value) {
                            clearCurrentConfigPresetIfExist()
                        }
                    }
                    if contentModel.config.isValid.valid {
                        Button(Constants.saveAppInfoAsPreset.value) {
                            saveAsPreset()
                        }
                    }

                    // Payload
                    Section(Constants.payload.value) {
                        PayloadEditor(payload: $contentModel.payload)
                            .frame(minHeight: 200)
                            .padding(.vertical, 12)
                    }
                    .listRowSeparator(.hidden)

                    Group {
                        Button( Constants.loadTemplatePayload.value) {
                            loadPayloadTemplate()
                        }

                        Button(Constants.clearPayload.value) {
                            contentModel.payload = .empty
                        }
                    }
                    .listRowSeparator(.hidden)

                    Section(Constants.log.value) {
                        // Log
                        LogView()
                    }
                    .id(Constants.log.value)
                    .listRowSeparator(.hidden)
                }
                .scrollDismissesKeyboard(.immediately)
                .onChange(of: appModel.isSendingPush) { _, isSendingPush in
                    guard !isSendingPush
                    else {
                        return
                    }
                    scrollView.scrollTo(Constants.log.value)
                }
            }

            // Send Button Area
            SendButtonArea(loadPayloadTemplate: loadPayloadTemplate)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
    }
}
