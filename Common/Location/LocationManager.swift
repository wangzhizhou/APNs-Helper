//
//  LocationManager.swift
//  APNs Helper
//
//  Created by joker on 11/4/23.
//

import Foundation
import CoreLocation
import Combine

/// 定位/定位推送的管理器。
///
/// 跨线程的共享状态只有 `locationPushTokenSubject`（Combine Subject 本身线程安全），
/// 其余状态只在主线程的 CLLocationManager 回调里访问，因此显式声明 @unchecked Sendable。
class LocationManager: NSObject, @unchecked Sendable {

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
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
        case .authorizedAlways:
#if os(iOS)
            manager.startMonitoringLocationPushes { token, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let tokenData = token {
                    let locationPushToken = tokenData.hexString
                    "location push token: \(locationPushToken)".printDebugInfo()
                    self.locationPushTokenSubject.send(locationPushToken)
                    self.locationPushTokenSubject.send(completion: .finished)
                }
            }
#endif
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}
