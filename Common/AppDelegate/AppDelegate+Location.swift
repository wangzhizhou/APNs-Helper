//
//  AppDelegate+Location.swift
//  APNs Helper
//
//  Created by joker on 11/3/23.
//

import Foundation
import CoreLocation

extension AppDelegate {
    
    static let locationManager = CLLocationManager()
    
    func setupLocationManager() {
        AppDelegate.locationManager.delegate = self
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
        case .authorizedAlways:
#if os(iOS)
            manager.startMonitoringLocationPushes { token, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let tokenData = token {
                    let locationPushToken = tokenData.hexString
                    print("location push token: \(locationPushToken)")
                }
            }
#endif
        default:
            break
        }
    }
}
