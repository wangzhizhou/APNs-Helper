//
//  FileProvider+Setup.swift
//  APNs Helper
//
//  Created by joker on 2023/5/19.
//

import FileProvider

extension NSFileProviderManager {
    
    static func setup() {
        
        self.add(NSFileProviderDomain(identifier: .init(Bundle.main.bundleIdentifier!), displayName: "Tester")) { error in
            error?.localizedDescription.printDebugInfo()
        }
    }
}
