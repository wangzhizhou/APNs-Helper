//
//  Data+Utils.swift
//  APNs Helper
//
//  Created by joker on 2023/4/5.
//

import Foundation

extension Data {
    
    var toPresetConfigs: [Config] {
        if let configs = try? JSONDecoder().decode([Config].self, from: self) {
            return configs
        } else {
            return []
        }
    }
    
}
