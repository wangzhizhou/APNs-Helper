//
//  InputTextEditor.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import SwiftUI

struct InputTextEditor: View {
    
    var title: String? = nil
    
    @Binding var content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = title {
                Text(title)
            }
            TextEditor(text: $content)
                .font(.system(size: 8))
        }
    }
}

struct InputTextEditor_Previews: PreviewProvider {
    
    @State static var detail: String = "content"
    
    static var previews: some View {
        InputTextEditor(title: "title", content: $detail)
            .frame(height: 100)
    }
}
