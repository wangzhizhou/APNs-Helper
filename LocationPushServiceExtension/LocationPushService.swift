//
//  LocationPushService.swift
//  LocationPushServiceExtension
//
//  Created by joker on 2023/11/3.
//

import CoreLocation

class LocationPushService: NSObject, CLLocationPushServiceExtension, CLLocationManagerDelegate {

    var completion: (() -> Void)?
    var locationManager: CLLocationManager?

    func didReceiveLocationPushPayload(_ payload: [String: Any], completion: @escaping () -> Void) {
        self.completion = completion
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        self.locationManager!.requestLocation()
        
        // Write Location Notification Payload into group user defaults
        if let groupUserDefault = UserDefaults(suiteName: "group.com.joker.APNsHelper.tester") {
            groupUserDefault.set(payload, forKey: "location_notification_payload")
        }
        // ----
    }
    
    func serviceExtensionWillTerminate() {
        // Called just before the extension will be terminated by the system.
        self.completion?()
    }

    // MARK: - CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Process the location(s) as appropriate
        // let location = locations.first

        // If sharing the locations to another user, end-to-end encrypt them to protect privacy
        // When finished, always call completion()
        self.completion?()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.completion?()
    }

}
