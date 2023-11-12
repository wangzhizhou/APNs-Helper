//
//  AppDelegate+PushKitCallKit.swift
//  APNs Helper
//
//  Created by joker on 2023/4/12.
//

extension AppDelegate {
    func setupPushKitAndCallKit() {
#if ENABLE_PUSHKIT
        PushKitManager.shared.setup()
#endif
    }
}
