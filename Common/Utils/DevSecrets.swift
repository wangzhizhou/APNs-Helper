//
//  DevSecrets.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import Foundation

/// 开发期便利数据。
///
/// 仓库是公开的，因此**不包含任何 APNs 授权私钥**。「Fill this App's Info」
/// 需要私钥时可任选一种方式：
///
/// 1. 在 App 里用「Import P8」导入自己的 `AuthKey_XXXX.p8`（推荐）；
/// 2. 本地写入 UserDefaults（不会进入仓库）：
///    ```bash
///    defaults write com.joker.APNsHelper APNsHelperDevPrivateKey "$(cat AuthKey_XXXX.p8)"
///    ```
///
/// 注意：私钥内容需要保留 PEM 的换行，导入/写入时请使用原始 .p8 文本。
enum DevSecrets {

    private static let privateKeyStoreKey = "APNsHelperDevPrivateKey"

    /// 本 App 自测用的 APNs 授权私钥，未配置时为空字符串。
    static var privateKey: String {
        UserDefaults.standard.string(forKey: privateKeyStoreKey) ?? .empty
    }
}
