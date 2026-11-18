//
//  AppInfoFields.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import SwiftUI

/// App 信息字段（KeyID / TeamID / BundleID / P8 / Token）。
///
/// iOS 用 `Form + Section`、macOS 用 `VStack`，容器不同但字段与联动逻辑完全一样，
/// 因此这里用 `@ViewBuilder` 函数而不是 View：函数返回的是「兄弟视图集合」，
/// 放进 `Form` 时 SwiftUI 仍会按行拆分（包成 View 会退化成一行）。
@MainActor
@ViewBuilder
func appInfoFields(
    appInfo: Binding<Config>,
    showFileImporter: Binding<Bool>,
    p8EditorHeight: CGFloat = 80,
    onRefreshTestMode: @escaping () -> Void,
    onFileImporterError: @escaping (Error) -> Void
) -> some View {
    InputView(
        title: Constants.keyid.value,
        inputValue: appInfo.keyIdentifier
    )
    .onChange(of: appInfo.wrappedValue.keyIdentifier) { onRefreshTestMode() }

    InputView(
        title: Constants.teamid.value,
        inputValue: appInfo.teamIdentifier
    )
    .onChange(of: appInfo.wrappedValue.teamIdentifier) { onRefreshTestMode() }

    InputView(
        title: Constants.bundleid.value,
        inputValue: appInfo.appBundleID
    )
    .onChange(of: appInfo.wrappedValue.appBundleID) { onRefreshTestMode() }

    P8KeyView(
        showFileImporter: showFileImporter,
        privateKey: appInfo.privateKey,
        editorHeight: p8EditorHeight,
        onPrivateKeyChange: { _ in onRefreshTestMode() },
        onFileImporterError: onFileImporterError
    )

    TokenView(
        pushType: appInfo.wrappedValue.pushType,
        deviceToken: appInfo.deviceToken,
        pushKitDeviceToken: appInfo.pushKitVoIPToken,
        fileProviderDeviceToken: appInfo.pushKitFileProviderToken,
        locationPushServiceToken: appInfo.locationPushServiceToken,
        liveActivityPushToken: appInfo.liveActivityPushToken
    )
}
