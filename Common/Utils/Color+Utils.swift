//
//  Color+Utils.swift
//  APNs Helper
//
//  Created by joker on 11/8/23.
//

import SwiftUI

extension Color {
    
    static var random: Color {
        .init(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
