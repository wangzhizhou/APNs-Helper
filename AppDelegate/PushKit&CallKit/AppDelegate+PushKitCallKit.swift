//
//  AppDelegate+PushKitCallKit.swift
//  APNs Helper
//
//  Created by joker on 2023/4/12.
//

extension AppDelegate {    
    func setupPushKitAndCallKit() {
#if ENABLE_VOIP
        PushKitManager.shared.setup()
#endif
    }
}

