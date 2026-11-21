//
//  AppContentIOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI

/// iOS 主界面：分组 `Form` + 固定在底部的发送按钮。
///
/// 这次按 HIG 收拢了几处：
/// - 危险操作（清空全部预设）用 `role: .destructive` 并二次确认
/// - 零散按钮归入所在 Section，不再是「悬空」的列表行
/// - 日志区只读、可选中复制
struct AppContentIOS: View {

    @Environment(AppModel.self) private var appModel
    @Environment(AppContentModel.self) private var contentModel

    @Environment(\.appActions) private var actions

    @State private var showClearAllPresetConfirm = false

    var body: some View {
        @Bindable var contentModel = contentModel

        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                Form {
                    if !appModel.presets.isEmpty {
                        Section {
                            PresetPicker(
                                presets: appModel.presets,
                                selectedPreset: $contentModel.presetConfig
                            ) { preset in
                                contentModel.appInfo = preset
                            }

                            Button(Constants.clearallpreset.value, role: .destructive) {
                                showClearAllPresetConfirm = true
                            }
                        } header: {
                            Text(Constants.preset.value)
                        }
                    }

                    Section {
                        Picker(Constants.pushtype.value, selection: $contentModel.appInfo.pushType) {
                            ForEach(contentModel.availablePushTypes, id: \.self) { pushType in
                                Text(pushType.rawValue).tag(pushType)
                            }
                        }
                        .onChange(of: contentModel.appInfo.pushType) { actions.loadPayloadTemplate() }

                        Picker(Constants.apnserver.value, selection: $contentModel.appInfo.apnsServerEnv) {
                            ForEach(APNServerEnv.allCases, id: \.self) { env in
                                Text(env.rawValue).tag(env)
                            }
                        }
                    } header: {
                        Text(Constants.pushSettings.value)
                    }

                    Section {
                        appInfoFields(
                            appInfo: $contentModel.appInfo,
                            showFileImporter: $contentModel.showFileImporter,
                            p8EditorHeight: 120,
                            onRefreshTestMode: { actions.refreshTestMode() },
                            onFileImporterError: { appModel.appLog.append($0.localizedDescription) }
                        )

                        Toggle(Constants.fillInAppInfo.value, isOn: $contentModel.isInTestMode)
                            .onChange(of: contentModel.isInTestMode) { _, mode in
                                contentModel.applyTestMode(mode, thisAppConfig: appModel.thisAppConfig)
                            }
                            .onChange(of: appModel.thisAppConfig) {
                                contentModel.syncWithTestConfig(appModel.thisAppConfig)
                            }

                        Button(Constants.importAppInfoOnPasteboard.value) {
                            contentModel.showPasteboardImportConfirm = true
                        }
                        .confirmationDialog(
                            "Import app info from the clipboard?",
                            isPresented: $contentModel.showPasteboardImportConfirm,
                            titleVisibility: .visible
                        ) {
                            Button("Import") { actions.importAppInfoOnPasteboard() }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("The clipboard may contain credentials such as your .p8 key. Import P8 from a file instead when possible.")
                        }

                        SelfTestCredentialsButton()

                        if contentModel.config.isValid.valid {
                            Button(Constants.saveAppInfoAsPreset.value) {
                                actions.saveAsPreset()
                            }
                        }

                        if !contentModel.appInfo.appBundleID.isEmpty {
                            Button(Constants.removeAppInfoFromPreset.value) {
                                actions.clearCurrentConfigPresetIfExist()
                            }
                        }

                        if !contentModel.config.isEmpty {
                            Button(Constants.clearCurrentAppInfo.value, role: .destructive) {
                                contentModel.clearAppInfo()
                            }
                        }
                    } header: {
                        Text(Constants.appInfo.value)
                    }

                    Section {
                        PayloadEditor(payload: $contentModel.payload)
                            .frame(height: Design.Metrics.payloadHeight)

                        Button(Constants.loadTemplatePayload.value) {
                            actions.loadPayloadTemplate()
                        }

                        if contentModel.supportsStructuredEditor {
                            Button(Constants.structuredEditor.value) {
                                contentModel.showStructuredEditor = true
                            }
                        }

                        if !contentModel.payload.isEmpty {
                            Button(Constants.clearPayload.value, role: .destructive) {
                                contentModel.payload = .empty
                            }
                        }
                    } header: {
                        Text(Constants.payload.value)
                    }

                    Section(Constants.log.value) {
                        LogView()
                    }
                    .id(Constants.log.value)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: appModel.isSendingPush) { _, isSendingPush in
                    guard !isSendingPush else { return }
                    withAnimation {
                        scrollView.scrollTo(Constants.log.value, anchor: .bottom)
                    }
                }
            }

            Divider()

            SendButtonArea(loadPayloadTemplate: actions.loadPayloadTemplate)
                .padding(.horizontal, Design.Spacing.section)
                .padding(.vertical, Design.Spacing.regular)
                .background(.bar)
        }
        .confirmationDialog(
            Constants.clearAllPresetConfirm.value,
            isPresented: $showClearAllPresetConfirm,
            titleVisibility: .visible
        ) {
            Button(Constants.clearallpreset.value, role: .destructive) {
                actions.clearAllPreset()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
