//
//  TesterAppModel.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import UIKit
import Combine

class TesterAppModel: ObservableObject {
    
    @Published
    var deviceToken: String
    
    @Published
    var pushKitToken: String
    
    @Published
    var showAlert: Bool
    
    var alertMessage: String {
        didSet {
            showAlert = true
        }
    }
    
    func copyToPasteboard(content: String) {
        UIPasteboard.general.string = content
    }
    
    
    private var cancellables = [AnyCancellable]()
    
    init(deviceToken: String = "", pushKitToken: String = "", showAlert: Bool = false, alertMessage: String = "") {
        self.deviceToken = deviceToken
        self.pushKitToken = pushKitToken
        self.showAlert = showAlert
        self.alertMessage = alertMessage
        
        let pushkitCancellable = PushKitManager.shared.pushKitTokenSubject.sink { pushKitToken in
            self.pushKitToken = pushKitToken
        }
        cancellables.append(pushkitCancellable)
        
        let deviceTokenCancellable = UNUserNotificationManager.shared.deviceTokenSubject.sink { deviceToken in
            self.deviceToken = deviceToken
        }
        cancellables.append(deviceTokenCancellable)
        
        let backgroundNotificationCancellable = UNUserNotificationManager.shared.backgroundNotificationSubject.sink { message in
            self.alertMessage = message
        }
        cancellables.append(backgroundNotificationCancellable)
    }
}
