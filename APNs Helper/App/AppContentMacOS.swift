//
//  AppContentMacOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import SwiftUI

/// macOS 主界面。
///
/// 布局说明：`Form` 在 macOS 上不自带滚动，长表单会被裁切，
/// 因此这里用 `ScrollView + GroupBox` 组合：GroupBox 是系统控件（分组容器），
/// 视觉上等同系统设置的分组表单，同时保证「窗口多小都能滚到日志」。
/// 之前是固定 632×828、不可滚动、不可缩放的窗口。
struct AppContentMacOS: View {

    @Environment(AppModel.self) private var appModel
    @Environment(AppContentModel.self) private var contentModel

    @Environment(\.appActions) private var actions

    @State private var showClearAllPresetConfirm = false

    var body: some View {
        @Bindable var contentModel = contentModel

        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Design.Spacing.section) {
                    if !appModel.presets.isEmpty {
                        section(Constants.preset.value) {
                            PresetPicker(
                                presets: appModel.presets,
                                selectedPreset: $contentModel.presetConfig
                            ) { preset in
                                contentModel.appInfo = preset
                            }

                            Button(Constants.clearallpreset.value, role: .destructive) {
                                showClearAllPresetConfirm = true
                            }
                        }
                    }

                    section(Constants.pushSettings.value) {
                        LabeledContent(Constants.pushtype.value) {
                            Picker(Constants.pushtype.value, selection: $contentModel.appInfo.pushType) {
                                ForEach(contentModel.availablePushTypes, id: \.self) { pushType in
                                    Text(pushType.rawValue).tag(pushType)
                                }
                            }
                            .labelsHidden()
                            .onChange(of: contentModel.appInfo.pushType) { actions.loadPayloadTemplate() }
                        }

                        LabeledContent(Constants.apnserver.value) {
                            Picker(Constants.apnserver.value, selection: $contentModel.appInfo.apnsServerEnv) {
                                ForEach(APNServerEnv.allCases, id: \.self) { env in
                                    Text(env.rawValue).tag(env)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.segmented)
                            .frame(maxWidth: 260)
                        }
                    }

                    section(Constants.appInfo.value) {
                        appInfoFields(
                            appInfo: $contentModel.appInfo,
                            showFileImporter: $contentModel.showFileImporter,
                            onRefreshTestMode: { actions.refreshTestMode() },
                            onFileImporterError: { appModel.appLog.append($0.localizedDescription) }
                        )

                        // macOS 上 Toggle 默认贴着标签，这里按「标签左、开关右」对齐
                        HStack {
                            Text(Constants.fillInAppInfo.value)
                            Spacer()
                            Toggle(Constants.fillInAppInfo.value, isOn: $contentModel.isInTestMode)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .onChange(of: contentModel.isInTestMode) { _, isInTestMode in
                                    contentModel.applyTestMode(isInTestMode, thisAppConfig: appModel.thisAppConfig)
                                }
                                .onChange(of: appModel.thisAppConfig) {
                                    contentModel.syncWithTestConfig(appModel.thisAppConfig)
                                }
                        }

                        HStack(spacing: Design.Spacing.regular) {
                            Button(Constants.clearIfExist.value) {
                                actions.clearCurrentConfigPresetIfExist()
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
                            Button(Constants.saveAsPreset.value) {
                                actions.saveAsPreset()
                            }
                            Spacer()
                        }
                    }

                    section(Constants.payload.value) {
                        PayloadEditor(payload: $contentModel.payload)
                            .frame(height: Design.Metrics.payloadHeight)

                        HStack(spacing: Design.Spacing.regular) {
                            Button(Constants.loadTemplatePayload.value) {
                                actions.loadPayloadTemplate()
                            }
                            Button(Constants.clearPayload.value) {
                                contentModel.payload = .empty
                            }
                            Spacer()
                            if contentModel.supportsStructuredEditor {
                                Button(Constants.structuredEditor.value) {
                                    contentModel.showStructuredEditor = true
                                }
                            }
                        }
                    }

                    section(Constants.log.value) {
                        LogView()
                    }
                }
                .padding(Design.Spacing.section)
            }

            Divider()

            SendButtonArea(loadPayloadTemplate: actions.loadPayloadTemplate)
                .padding(.horizontal, Design.Spacing.section)
                .padding(.vertical, Design.Spacing.regular)
                .background(.bar)
        }
        .frame(minWidth: 620, minHeight: 600)
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

    /// 系统分组容器 + 区块标题（对应 iOS `Section` 的视觉层级）
    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: Design.Spacing.regular) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Design.Spacing.compact)
        } label: {
            Text(title)
                .font(.headline)
        }
    }
}
