//
//  DevSecrets.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import Foundation

/// 「Fill this App's Info」（自收发自测）需要的开发者凭据。
///
/// 仓库是公开的，**不含任何 APNs 授权私钥（.p8）**，构建产物里也没有。
/// 凭据由用户在本机的 App 内录入一次（App Info → Self-Test Credentials…），
/// 存进 **Keychain**：不随 `UserDefaults` 备份同步，也不会被 `defaults read` 直接读出。
///
/// 读取顺序：
/// 1. Keychain（App 内录入 / 覆盖）
/// 2. **构建时注入的 bundle 资源** `DevSecrets.plist`（`Scripts/setup-dev-secrets.sh`
///    生成，`Scripts/inject-dev-secrets.sh` 在构建阶段拷进 App；仓库里没有该文件）
/// 3. 早期 `defaults write com.joker.APNsHelper APNsHelperDevPrivateKey ...`（兼容旧版）
enum DevSecrets {

    /// 自测配置：Key ID、Team ID、.p8 私钥
    struct Payload: Codable, Equatable {
        var keyIdentifier: String
        var teamIdentifier: String
        var privateKey: String
    }

    /// 非机密默认值：本仓库 App 的 Key ID / Team ID 本来就是公开信息
    static let defaultKeyIdentifier = "7S6SUT5L43"
    static let defaultTeamIdentifier = "2N62934Y28"

    private static let account = "dev-self-test"
    private static let resourceName = "DevSecrets"
    private static let legacyDefaultsKey = "APNsHelperDevPrivateKey"
    private static let pemBegin = "-----BEGIN PRIVATE KEY-----"
    private static let pemEnd = "-----END PRIVATE KEY-----"

    // MARK: 读取

    /// Keychain 中保存的自测配置；未录入时为 nil
    static var current: Payload? {
        guard let data = KeychainStore.data(for: account) else { return nil }
        return decode(data)
    }

    /// 本 App 自测用的 APNs 授权私钥，未配置时为空字符串
    static var privateKey: String {
        if let stored = current, !stored.privateKey.isEmpty {
            return stored.privateKey
        }
        if let bundled = bundled, !bundled.privateKey.isEmpty {
            return bundled.privateKey
        }
        return UserDefaults.standard.string(forKey: legacyDefaultsKey) ?? .empty
    }

    /// 构建时注入到 bundle 的自测凭据（本机专用，CI 与他人克隆时不存在）
    static var bundled: Payload? {
        guard let data = bundledData else { return nil }
        return payload(fromPropertyList: data)
    }

    private static var bundledData: Data? {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "plist") else { return nil }
        return try? Data(contentsOf: url)
    }

    static var keyIdentifier: String {
        nonEmpty(current?.keyIdentifier) ?? nonEmpty(bundled?.keyIdentifier) ?? defaultKeyIdentifier
    }

    static var teamIdentifier: String {
        nonEmpty(current?.teamIdentifier) ?? nonEmpty(bundled?.teamIdentifier) ?? defaultTeamIdentifier
    }

    /// 是否已经录入过私钥（决定自测模式是否可用）
    static var isConfigured: Bool {
        !privateKey.trimmed.isEmpty
    }

    // MARK: 写入

    static func save(keyIdentifier: String, teamIdentifier: String, privateKey: String) throws {
        let payload = Payload(
            keyIdentifier: keyIdentifier.trimmed,
            teamIdentifier: teamIdentifier.trimmed,
            privateKey: normalize(privateKey)
        )
        guard let data = encode(payload) else { return }
        try KeychainStore.set(data, for: account)
        // 迁移完成后清掉旧的 UserDefaults 明文副本
        UserDefaults.standard.removeObject(forKey: legacyDefaultsKey)
    }

    static func clear() {
        KeychainStore.remove(account)
        UserDefaults.standard.removeObject(forKey: legacyDefaultsKey)
    }

    // MARK: 校验

    /// 返回 nil 表示可以保存；否则返回给用户看的错误文案
    static func validationError(
        keyIdentifier: String,
        teamIdentifier: String,
        privateKey: String
    ) -> String? {
        let keyID = keyIdentifier.trimmed
        let teamID = teamIdentifier.trimmed
        let key = normalize(privateKey)

        if keyID.isEmpty { return "Key ID is required." }
        if keyID.count != 10 { return "Key ID should be 10 characters." }
        if teamID.isEmpty { return "Team ID is required." }
        if teamID.count != 10 { return "Team ID should be 10 characters." }
        if key.isEmpty { return ".p8 private key is required." }
        if !key.hasPrefix(pemBegin) || !key.hasSuffix(pemEnd) {
            return ".p8 must be a PKCS#8 PEM block (BEGIN/END PRIVATE KEY)."
        }
        // PEM 主体至少要有若干行 base64，避免误粘半截内容
        let body = key
            .replacingOccurrences(of: pemBegin, with: "")
            .replacingOccurrences(of: pemEnd, with: "")
            .trimmed
        if body.count < 100 { return ".p8 content looks truncated." }
        return nil
    }

    // MARK: Codable

    static func encode(_ payload: Payload) -> Data? {
        try? JSONEncoder().encode(payload)
    }

    static func decode(_ data: Data) -> Payload? {
        try? JSONDecoder().decode(Payload.self, from: data)
    }

    /// 解析构建注入的 `DevSecrets.plist`（KeyID / TeamID / PrivateKey 三个字符串）
    static func payload(fromPropertyList data: Data) -> Payload? {
        guard let plist = try? PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) as? [String: Any],
            let keyIdentifier = plist["KeyID"] as? String,
            let teamIdentifier = plist["TeamID"] as? String,
            let privateKey = plist["PrivateKey"] as? String
        else { return nil }

        return Payload(
            keyIdentifier: keyIdentifier.trimmed,
            teamIdentifier: teamIdentifier.trimmed,
            privateKey: normalize(privateKey)
        )
    }

    // MARK: 私有

    /// 统一换行 & 去掉首尾空白：文件导入与手动粘贴的文本都能直接用于 JWT 签名
    static func normalize(_ privateKey: String) -> String {
        privateKey
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .trimmed
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value = value?.trimmed, !value.isEmpty else { return nil }
        return value
    }
}
