//
//  InputView.swift
//  APNs Helper
//
//  Created by joker on 2022/9/28.
//

import SwiftUI

struct InputView: View {
    
    let title: String
    
    var placeholder: String? = nil
    
    @Binding var inputValue: String
    
    var body: some View {
        HStack {
            Text(title)
            TextField(placeholder ?? title, text: $inputValue)
                .frame(width: 420)
        }
    }
}

struct InputView_Previews: PreviewProvider {
    
    @State static var value: String = ""
    
    static var previews: some View {
        
        InputView(
            title: "Title",
            inputValue: $value)
        
    }
}
