//
//  TesterAppModel.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//
#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

#if canImport(ActivityKit)
import ActivityKit
#endif

import Combine

class TesterAppModel: ObservableObject {
    
#if canImport(ActivityKit)
    var liveActivity: Activity<LiveActivityAttributes>? {
        didSet {
            guard let activity = liveActivity
            else {
                appInfo.liveActivityPushToken = ""
                return
            }
            
            Task {
                for await pushToken in activity.pushTokenUpdates {
                    pushToken.hexString.printDebugInfo()
                    
                    await MainActor.run {
                        appInfo.liveActivityPushToken = pushToken.hexString
                    }
                }
            }
        }
    }
    
    enum LiveActivityStage: String, Codable {
        case start
        case update
        case end
        case dismiss
    }
    
    @Published var stage: LiveActivityStage = .start
    
#endif
    
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
    
    @Published var showToast: Bool
    var toastModel: ToastModel {
        didSet {
            Task {
                await MainActor.run {
                    showToast = toastModel.shouldShow
                }
            }
        }
    }
    
    var content: [(String, String)] {[
        (Constants.keyid.value, appInfo.keyID),
        (Constants.teamid.value, appInfo.teamID),
        (Constants.bundleid.value, appInfo.bundleID),
        (Constants.p8key.value, appInfo.p8Key),
        (Constants.devicetoken.value, appInfo.deviceToken),
        (Constants.voiptoken.value, appInfo.voipToken),
        (Constants.fileprovidertoken.value, appInfo.fileProviderToken),
        (Constants.locationPushServiceToken.value, appInfo.locationPushToken),
        (Constants.liveactivityPushToken.value, appInfo.liveActivityPushToken)
    ]}
    
    private var cancellables = [AnyCancellable]()
    
    init(
        showAlert: Bool = false,
        alertMessage: String = "",
        showToast: Bool = false,
        toastModel: ToastModel = ToastModel.info()) {
            self.showAlert = showAlert
            self.alertMessage = alertMessage
            self.showToast = showToast
            self.toastModel = toastModel
            
            let deviceTokenCancellable = UNUserNotificationManager.shared.deviceTokenSubject.sink { deviceToken in
                self.appInfo.deviceToken = deviceToken
            }
            cancellables.append(deviceTokenCancellable)
            
            let backgroundNotificationCancellable = UNUserNotificationManager.shared.backgroundNotificationSubject.sink { message in
                self.alertMessage = message
            }
            cancellables.append(backgroundNotificationCancellable)
            
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
            
            let locationPushTokenCancellable = LocationManager.shared.locationPushTokenSubject.sink { locationPushToken in
                self.appInfo.locationPushToken = locationPushToken
            }
            cancellables.append(locationPushTokenCancellable)
            
            let copyToPasteboardCancellable = NotificationCenter.default.publisher(for: .APNSHelperStringCopyedToPastedboard).sink { _ in
                self.toastModel = ToastModel.success().title("Copyed to Pasteboard!")
            }
            cancellables.append(copyToPasteboardCancellable)
            
            
        }
    
    func copyAllInfo() {
        appInfo.formattedText?.copyToPasteboard()
    }
    
    func checkReceiveLocationNotification() {
        
        if  let groupUserDefaults = UserDefaults(suiteName: "group.com.joker.APNsHelper.tester"),
            let locationNotificationPayloadDict = groupUserDefaults.dictionary(forKey: "location_notification_payload"),
            let jsonString = locationNotificationPayloadDict.jsonString {
            self.alertMessage = "location_push_payload: \(jsonString)"
            groupUserDefaults.set(nil, forKey: "location_notification_payload")
        }
    }
}
