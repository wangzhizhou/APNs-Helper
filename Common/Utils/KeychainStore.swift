//
//  KeychainStore.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import Foundation
import Security

/// 极简 Keychain 封装（generic password）。
///
/// 预设里含有 `.p8` 私钥与 device token，属于凭据，不适合放 `UserDefaults`
/// （会随设备备份、在 macOS 上可被 `defaults read` 直接读出）。
enum KeychainStore {

    enum KeychainError: LocalizedError {
        case unexpectedStatus(OSStatus)

        var errorDescription: String? {
            switch self {
            case .unexpectedStatus(let status):
                return "Keychain error: \(status)"
            }
        }
    }

    private static let service = "com.joker.APNsHelper.credentials"

    static func data(for account: String) -> Data? {
        var query = baseQuery(for: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    static func string(for account: String) -> String? {
        data(for: account).flatMap { String(data: $0, encoding: .utf8) }
    }

    static func set(_ value: Data, for account: String) throws {
        let query = baseQuery(for: account)
        let attributes: [String: Any] = [
            kSecValueData as String: value,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        } else {
            var insert = query
            attributes.forEach { insert[$0.key] = $0.value }
            let addStatus = SecItemAdd(insert as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(addStatus)
            }
        }
    }

    static func set(_ value: String, for account: String) throws {
        try set(Data(value.utf8), for: account)
    }

    static func remove(_ account: String) {
        SecItemDelete(baseQuery(for: account) as CFDictionary)
    }

    private static func baseQuery(for account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
