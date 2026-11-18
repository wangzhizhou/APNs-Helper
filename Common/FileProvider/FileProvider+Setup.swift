//
//  FileProvider+Setup.swift
//  APNs Helper
//
//  Created by joker on 2023/5/19.
//

import Foundation
import FileProvider

extension NSFileProviderManager {

    /// 注册 File Provider 域。
    ///
    /// 之前这里是空的：没有域，系统就不会启动扩展，也就无法验证 FileProvider 推送的效果。
    /// 现在幂等注册，并把结果写进 `FileProviderEventLog`，可在 Tester 里查看。
    static func setup() {
        let identifier = NSFileProviderDomainIdentifier("APNsHelperTester")

        getDomainsWithCompletionHandler { domains, error in
            if let error {
                FileProviderEventLog.record("getDomains failed", detail: error.localizedDescription)
                return
            }
            if domains.contains(where: { $0.identifier == identifier }) {
                FileProviderEventLog.record("domain exists", detail: identifier.rawValue)
                return
            }

            let domain = NSFileProviderDomain(
                identifier: identifier,
                displayName: "APNs Helper Tester"
            )
            add(domain) { error in
                FileProviderEventLog.record(
                    "domain added",
                    detail: error?.localizedDescription ?? "ok"
                )
            }
        }
    }
}
