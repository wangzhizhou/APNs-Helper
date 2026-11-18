//
//  AppContentIOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI

struct AppContentIOS: View {

    @Environment(AppModel.self) private var appModel
    @Environment(AppContentModel.self) private var contentModel

    @Environment(\.appActions) private var actions

    var body: some View {
        @Bindable var contentModel = contentModel

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

                        appInfoFields(
                            appInfo: $contentModel.appInfo,
                            showFileImporter: $contentModel.showFileImporter,
                            titleWidth: 70,
                            p8EditorHeight: 120,
                            onRefreshTestMode: { actions.refreshTestMode() },
                            onFileImporterError: { appModel.appLog.append($0.localizedDescription) }
                        )

                        Toggle(isOn: $contentModel.isInTestMode) {
                            Text(Constants.fillInAppInfo.value)
                        }
                        .onChange(of: contentModel.isInTestMode) { _, mode in
                            contentModel.applyTestMode(mode, thisAppConfig: appModel.thisAppConfig)
                        }
                        .onChange(of: appModel.thisAppConfig) {
                            contentModel.syncWithTestConfig(appModel.thisAppConfig)
                        }
                        Button(Constants.importAppInfoOnPasteboard.value, action: { actions.importAppInfoOnPasteboard() })
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
