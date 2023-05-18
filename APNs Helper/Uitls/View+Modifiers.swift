//
//  View+Modifiers.swift
//  APNs Helper
//
//  Created by joker on 2023/5/18.
//

import SwiftUI

extension View {
    
    func editorBorder() -> some View {
        return self.modifier(BorderModifier(color: Color.border, padding: 10))
    }
    
    func textFieldBorder() -> some View {
        return self
            .textFieldStyle(.plain)
            .modifier(BorderModifier(color: Color.border, padding: 6))
    }
    
    func textFieldUnderLine() -> some View {
        return self
            .modifier(UnderLineModifier())
    }
}
