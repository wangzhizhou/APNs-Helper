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

                appInfoFields(
                    appInfo: $contentModel.appInfo,
                    showFileImporter: $contentModel.showFileImporter,
                    titleWidth: 60,
                    onRefreshTestMode: { actions.refreshTestMode() },
                    onFileImporterError: { appModel.appLog.append($0.localizedDescription) }
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
                    .onChange(of: contentModel.isInTestMode) { _, isInTestMode in
                        contentModel.applyTestMode(isInTestMode, thisAppConfig: appModel.thisAppConfig)
                    }
                    .onChange(of: appModel.thisAppConfig) {
                        contentModel.syncWithTestConfig(appModel.thisAppConfig)
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
