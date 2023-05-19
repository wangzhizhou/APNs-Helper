//
//  AppDelegate+FileProvider.swift
//  APNs Helper
//
//  Created by joker on 2023/5/19.
//

import FileProvider

extension AppDelegate {
    func setupFileProvider() {
        NSFileProviderManager.setup()
    }
}
