//
//  LocationManager.swift
//  APNs Helper
//
//  Created by joker on 11/4/23.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject {
    
    // MARK: 单例实现
    static let shared = LocationManager()
    private override init() {}
    private let locationManager = CLLocationManager()
    
    // MARK: 功能
    func setup() {
        locationManager.delegate = self
    }
    
    let locationPushTokenSubject = PassthroughSubject<String, Never>()
}

extension LocationManager: CLLocationManagerDelegate {
    
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
                    self.locationPushTokenSubject.send(locationPushToken)
                    self.locationPushTokenSubject.send(completion: .finished)
                }
            }
#endif
        default:
            break
        }
    }
}
