//
//  FileProvider+Setup.swift
//  APNs Helper
//
//  Created by joker on 2023/5/19.
//

import FileProvider

extension NSFileProviderManager {

    static func setup() {

        guard let bundleIdentifier = Bundle.main.bundleIdentifier, bundleIdentifier == "com.joker.APNsHelper.tester"
        else {
            return
        }
        
        NSFileProviderManager.add(.init(identifier: .init(bundleIdentifier), displayName: "fileProvider")) { error in
            error?.localizedDescription.printDebugInfo()
        }
    }
}
