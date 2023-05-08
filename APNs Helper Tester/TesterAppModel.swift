//
//  TesterAppModel.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import UIKit
import Combine

class TesterAppModel: ObservableObject {
    
    private let keyId = "7S6SUT5L43"
    
    private let teamID = "2N62934Y28"
    
    private let bundleId = Bundle.main.bundleIdentifier!
    
    @Published
    private var deviceToken: String
    
    @Published
    private var pushKitToken: String
    
    private let P8Key = """
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgViPOgSdnJxJ2gXfH
    iFJM4tkQhhakxYWGek6Ozwm2wkWhRANCAATiYzEZHM2oniKXJHZK123blIlSQUTp
    n2c05lXz66Ifu6eCVNoXignIS5SmDYS29CchZHQzXrinraNSTTNKgMo+
    -----END PRIVATE KEY-----
    """
    
    @Published
    var showAlert: Bool
    
    var alertMessage: String {
        didSet {
            showAlert = true
        }
    }
    
    var content: [(String, String)] {[
        ("Key ID", keyId),
        ("Team ID", teamID),
        ("BundleID",bundleId),
        ("P8 Key", P8Key),
        ("Device Token", deviceToken),
        ("PushKit Device Token", pushKitToken),
    ]}
    
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
            UIPasteboard.general.string = nil
            self.alertMessage = message
        }
        cancellables.append(backgroundNotificationCancellable)
        
        let copyToPasteboardCancellable = NotificationCenter.default.publisher(for: .APNSHelperStringCopyedToPastedboard).sink { _ in
            self.alertMessage = "Copyed To Pasteboard!"
        }
        cancellables.append(copyToPasteboardCancellable)
    }
    
    func copyAllInfo() {
        content.reduce("") { partialResult, element in
            "\(partialResult)\(element.0):\n\(element.1)\n"
        }
        .trimmed
        .copyToPasteboard()
        alertMessage = "All Info Copyed!"
    }
}
