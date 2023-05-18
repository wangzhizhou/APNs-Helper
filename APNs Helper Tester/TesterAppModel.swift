//
//  TesterAppModel.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import UIKit
import Combine

class TesterAppModel: ObservableObject {
        
    @Published var appInfo = AppInfo(
        keyID: "7S6SUT5L43",
        teamID: "2N62934Y28",
        bundleID: Bundle.main.bundleIdentifier!,
        p8Key: """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgViPOgSdnJxJ2gXfH
        iFJM4tkQhhakxYWGek6Ozwm2wkWhRANCAATiYzEZHM2oniKXJHZK123blIlSQUTp
        n2c05lXz66Ifu6eCVNoXignIS5SmDYS29CchZHQzXrinraNSTTNKgMo+
        -----END PRIVATE KEY-----
        """
    )
    
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
        (Constants.keyid.value, appInfo.keyID),
        (Constants.teamid.value, appInfo.teamID),
        (Constants.bundleid.value,appInfo.bundleID),
        (Constants.p8key.value, appInfo.p8Key),
        (Constants.devicetoken.value, appInfo.deviceToken),
        (Constants.voiptoken.value, appInfo.voipToken),
        (Constants.fileprovidertoken.value, appInfo.fileProviderToken),
    ]}
    
    func copyToPasteboard(content: String) {
        UIPasteboard.general.string = content
    }
    
    private var cancellables = [AnyCancellable]()
    
    init(
        showAlert: Bool = false,
        alertMessage: String = "",
        showToast: Bool = false,
        toastMessage: String = "") {
            self.showAlert = showAlert
            self.alertMessage = alertMessage
            self.showToast = showToast
            self.toastMessage = toastMessage
            
            let pushkitCancellable = PushKitManager.shared.pushKitTokenSubject.sink { pushKitTokenInfo in
                let (pushKitToken, type) = pushKitTokenInfo
                switch type {
                case .voip:
                    self.appInfo.voipToken = pushKitToken
                case .fileprovider:
                    self.appInfo.fileProviderToken = pushKitToken
                default:
                    break
                }
                
            }
            cancellables.append(pushkitCancellable)
            
            let deviceTokenCancellable = UNUserNotificationManager.shared.deviceTokenSubject.sink { deviceToken in
                self.appInfo.deviceToken = deviceToken
            }
            cancellables.append(deviceTokenCancellable)
            
            let backgroundNotificationCancellable = UNUserNotificationManager.shared.backgroundNotificationSubject.sink { message in
                self.alertMessage = message
            }
            cancellables.append(backgroundNotificationCancellable)
            
            let copyToPasteboardCancellable = NotificationCenter.default.publisher(for: .APNSHelperStringCopyedToPastedboard).sink { _ in
                self.toastMessage = "Copyed!"
            }
            cancellables.append(copyToPasteboardCancellable)
        }
    
    func copyAllInfo() {
        appInfo.jsonString?.copyToPasteboard()
    }
}
