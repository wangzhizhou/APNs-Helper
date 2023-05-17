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
    private var pushKitVoIPToken: String
    
    @Published
    private var pushKitFileProviderToken: String
    
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
    
    @Published
    var showToast: Bool
    var toastMessage: String {
        didSet {
            showToast = true
        }
    }
    
    var content: [(String, String)] {[
        ("Key ID", keyId),
        ("Team ID", teamID),
        ("BundleID",bundleId),
        ("P8 Key", P8Key),
        ("Device Token", deviceToken),
        ("VoIP Token", pushKitVoIPToken),
        ("File Provider Token", pushKitFileProviderToken),
    ]}
    
    func copyToPasteboard(content: String) {
        UIPasteboard.general.string = content
    }
    
    private var cancellables = [AnyCancellable]()
    
    init(
        deviceToken: String = "",
        pushKitVoIPToken: String = "",
        pushKitFileProviderToken: String = "",
        showAlert: Bool = false,
        alertMessage: String = "",
        showToast: Bool = false,
        toastMessage: String = "") {
            self.deviceToken = deviceToken
            self.pushKitVoIPToken = pushKitVoIPToken
            self.pushKitFileProviderToken = pushKitFileProviderToken
            self.showAlert = showAlert
            self.alertMessage = alertMessage
            self.showToast = showToast
            self.toastMessage = toastMessage
            
            let pushkitCancellable = PushKitManager.shared.pushKitTokenSubject.sink { pushKitTokenInfo in
                let (pushKitToken, type) = pushKitTokenInfo
                switch type {
                case .voip:
                    self.pushKitVoIPToken = pushKitToken
                case .fileprovider:
                    self.pushKitFileProviderToken = pushKitToken
                default:
                    break
                }
                
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
                self.toastMessage = "Copyed in Pasteboard!"
            }
            cancellables.append(copyToPasteboardCancellable)
        }
    
    func copyAllInfo() {
        content.reduce("") { partialResult, element in
            "\(partialResult)\(element.0):\n\(element.1)\n"
        }
        .trimmed
        .copyToPasteboard()
    }
}
