//
//  ConfigTests.swift
//  APNs Helper Tests
//
//  Created by joker on 2025/11/17.
//

import Foundation
import Testing

@Suite("Config")
struct ConfigTests {

    private func makeConfig(
        deviceToken: String = "device-token",
        voipToken: String = "voip-token",
        fileProviderToken: String = "fileprovider-token",
        locationToken: String = "location-token",
        liveActivityToken: String = "liveactivity-token",
        bundleID: String = "com.example.app",
        privateKey: String = "-----BEGIN PRIVATE KEY-----key-----END PRIVATE KEY-----",
        keyID: String = "KEYID12345",
        teamID: String = "TEAMID1234",
        pushType: PushType = .alert
    ) -> Config {
        Config(
            deviceToken: deviceToken,
            pushKitVoIPToken: voipToken,
            pushKitFileProviderToken: fileProviderToken,
            locationPushServiceToken: locationToken,
            liveActivityPushToken: liveActivityToken,
            appBundleID: bundleID,
            privateKey: privateKey,
            keyIdentifier: keyID,
            teamIdentifier: teamID,
            pushType: pushType,
            apnsServerEnv: .sandbox
        )
    }

    @Test("完整配置合法")
    func validConfig() {
        let result = makeConfig().isValid
        #expect(result.valid)
        #expect(result.message == nil)
    }

    @Test("缺少 KeyID 时提示 KeyID")
    func missingKeyID() {
        let result = makeConfig(keyID: .empty).isValid
        #expect(!result.valid)
        #expect(result.message == Constants.keyid.value)
    }

    @Test("缺少 TeamID 时提示 TeamID")
    func missingTeamID() {
        let result = makeConfig(teamID: .empty).isValid
        #expect(!result.valid)
        #expect(result.message == Constants.teamid.value)
    }

    @Test("缺少 BundleID 时提示 BundleID")
    func missingBundleID() {
        let result = makeConfig(bundleID: .empty).isValid
        #expect(!result.valid)
        #expect(result.message == Constants.bundleid.value)
    }

    @Test("缺少 P8 Key 时提示 P8 Key")
    func missingPrivateKey() {
        let result = makeConfig(privateKey: .empty).isValid
        #expect(!result.valid)
        #expect(result.message == Constants.p8key.value)
    }

    @Test("各推送类型要求各自的 Token", arguments: PushType.allCases)
    func requiresTokenForPushType(_ pushType: PushType) {
        // 所有 token 都为空时都应判定为不可发送
        let empty = makeConfig(
            deviceToken: .empty,
            voipToken: .empty,
            fileProviderToken: .empty,
            locationToken: .empty,
            liveActivityToken: .empty,
            pushType: pushType
        )
        let emptyResult = empty.isReadyForSend
        #expect(!emptyResult.ready)
        #expect(emptyResult.message == "Token")

        // 该类型对应的 token 填上后可发送
        let ready = makeConfig(pushType: pushType)
        #expect(ready.isReadyForSend.ready)
    }

    @Test("Preset 的 JSON 序列化可往返", arguments: PushType.allCases)
    func presetRoundTrip(_ pushType: PushType) throws {
        let presets = [makeConfig(pushType: pushType), makeConfig(bundleID: "com.example.other")]
        let data = try JSONEncoder().encode(presets)
        #expect(data.toPresetConfigs == presets)
    }

    @Test("非法数据解析为空的 Preset 列表")
    func invalidPresetData() {
        #expect(Data("not json".utf8).toPresetConfigs.isEmpty)
    }

    @Test("trimmed 去掉首尾空白")
    func trimmedConfig() {
        let config = makeConfig(bundleID: "  com.example.app ", keyID: " KEYID ", teamID: "\nTEAM ")
        #expect(config.trimmed.appBundleID == "com.example.app")
        #expect(config.trimmed.keyIdentifier == "KEYID")
        #expect(config.trimmed.teamIdentifier == "TEAM")
    }
}
