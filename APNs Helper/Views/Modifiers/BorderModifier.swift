//
//  BorderModifier.swift
//  APNs Helper
//
//  Created by joker on 2023/5/18.
//

import SwiftUI

struct BorderModifier: ViewModifier {
    
    let color: Color
    var padding: CGFloat = 10
    
    func body(content: Content) -> some View {
        return content
            .padding(padding)
            .overlay {
                RoundedRectangle(cornerRadius: padding / 2.0, style: .continuous)
                    .stroke()
                    .foregroundColor(Color.border)
            }
    }
}
