//
//  AppContentIOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI

struct AppContentIOS: View {

    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var contentModel: AppContentModel

    @Environment(\.appActions) private var actions

    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                Form {
                    // Preset
                    if !appModel.presets.isEmpty {
                        PresetPicker(presets: appModel.presets, selectedPreset: $contentModel.presetConfig) { preset in
                            contentModel.appInfo = preset
                        }
                        Button(Constants.clearallpreset.value, action: { actions.clearAllPreset() })
                    }

                    // Push Type & APN Server
                    Section(Constants.apnserver.value) {
                        Picker(Constants.pushtype.value, selection: $contentModel.appInfo.pushType) {
                            ForEach(PushType.allCases.filter {
                                !contentModel.isInTestMode || $0 != .fileprovider
                            }, id: \.self) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .onChange(of: contentModel.appInfo.pushType, { actions.loadPayloadTemplate() })

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
                            editorHeight: 120) { _ in
                                actions.refreshTestMode()
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
                        Button(Constants.importAppInfoOnPasteboard.value, action: { actions.importAppInfoOnPasteboard() })
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
                            actions.clearCurrentConfigPresetIfExist()
                        }
                    }
                    if contentModel.config.isValid.valid {
                        Button(Constants.saveAppInfoAsPreset.value) {
                            actions.saveAsPreset()
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
                            actions.loadPayloadTemplate()
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
            SendButtonArea(loadPayloadTemplate: actions.loadPayloadTemplate)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
    }
}
