//
//  InputView.swift
//  APNs Helper
//
//  Created by joker on 2022/9/28.
//

import SwiftUI

struct InputView: View {
    
    @EnvironmentObject var appModel: AppModel
    
    let title: String
    
    var placeholder: String?
    
    @Binding var inputValue: String
    
    @FocusState private var focusState: Bool
    
    var body: some View {
        HStack {
            Text(title)
            TextField(placeholder ?? title, text: $inputValue)
                .lineLimit(nil)
#if os(iOS)
                .keyboardType(.asciiCapable)
#endif
                .focused($focusState)
                .onSubmit {
                    focusState = false
                }
                .onChange(of: inputValue) { newValue in
                    let trimmedValue = newValue.replacingOccurrences(of: " ", with: "")
                    guard trimmedValue == newValue else {
                        inputValue = trimmedValue
                        return
                    }
                }
            
#if os(iOS)
            if !inputValue.isEmpty {
                HStack {
                    Button {
                        inputValue = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    Button {
                        inputValue.copyToPasteboard()
                    } label: {
                        Image(systemName: "doc.on.doc.fill")
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
#endif
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
