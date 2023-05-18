//
//  UnderLineModifier.swift
//  APNs Helper
//
//  Created by joker on 2023/5/18.
//

import SwiftUI

struct UnderLineModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .overlay(alignment: .bottom) {
                Divider()
                    .frame(height: 1)
                    .background(Color.border)
                    .offset(y: 4)
            }
    }
}
