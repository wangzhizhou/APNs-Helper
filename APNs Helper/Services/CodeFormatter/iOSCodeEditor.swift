//
//  iOSCodeEditor.swift
//  APNs Helper
//
//  Created by joker on 2023/5/12.
//

#if os(iOS)

import UIKit
import SwiftUI

struct iOSCodeEditor: UIViewRepresentable {
    
    @EnvironmentObject var appModel: AppModel
    
    @Binding var content: String
    
    var language: CodeFomater.Language? = nil
    
    let size: CGSize
    
    let colorScheme: ColorScheme
    
    var onError: ((Error?) -> Void)? = nil
    
    func makeUIView(context: Context) -> UITextView {
        CodeFomater.resetTheme(colorScheme: colorScheme)
        let frame = CGRect(origin: .zero, size: size)
        let textView = UITextView(frame: frame, textContainer: CodeFomater.highlightTextContainer(language: language))
        textView.delegate = context.coordinator
        textView.autocorrectionType = .no
        textView.smartQuotesType = .no
        textView.backgroundColor = .clear
        return textView
    }
    
    func format(_ textView: UITextView) {
        do {
            
            guard !textView.isDragging, !textView.isTracking, !textView.isDecelerating else {
                return
            }
            let newText = try CodeFomater.format(content, language: language)
            if let onError = onError {
                onError(nil)
            }
            guard textView.text != newText else {
                return
            }
            textView.text = newText
        } catch let error {
            if let onError = onError {
                onError(error)
            }
        }
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        format(textView)
    }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        
        let parent: iOSCodeEditor
        
        init(parent: iOSCodeEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            guard parent.content != textView.text else {
                return
            }
            parent.content = textView.text
        }
    }
}

struct iOSCodeEditor_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            
            iOSCodeEditor(
                content: .constant("""
                {
                "h1": 1
                }
                """),
                language: .json,
                size: geometry.size,
                colorScheme: .dark
            )
        }
    }
}

#endif
