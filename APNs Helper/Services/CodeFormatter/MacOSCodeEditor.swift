//
//  MacOSCodeEditor.swift
//  APNs Helper
//
//  Created by joker on 2023/5/12.
//

#if os(macOS)

import AppKit
import SwiftUI

struct MacOSCodeEditor: NSViewRepresentable {
    
    @Binding var content: String
    
    var language: CodeFomater.Language? = nil
    
    let size: CGSize
    
    var onError: ((Error?) -> Void)? = nil
    
    func makeNSView(context: Context) -> NSTextView {
        let frame = CGRect(origin: .zero, size: size)
        let highlighter = CodeFomater.highlightTextContainer(language: language)
        let textView = NSTextView(frame: frame, textContainer: highlighter)
        textView.delegate = context.coordinator
        textView.allowsUndo = true
        textView.enabledTextCheckingTypes = 0
        return textView
    }
    func format(_ textView: NSTextView) {
        do {
            let newString = try CodeFomater.format(content, language: language)
            if let onError = onError {
                onError(nil)
            }
            guard textView.string != newString else {
                return
            }
            textView.string = newString
        } catch let error {
            if let onError = onError {
                onError(error)
            }
        }
    }
    func updateNSView(_ textView: NSTextView, context: Context) {
        format(textView)
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSTextView, context: Context) -> CGSize? {
        return size
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, NSTextViewDelegate {
        
        let parent: MacOSCodeEditor
        
        init(parent: MacOSCodeEditor) {
            self.parent = parent
        }
        func textDidChange(_ notification: Notification) {
            if let text = notification.object as? NSText, parent.content != text.string {
                parent.content = text.string
            }
        }
    }
}

struct MacOSCodeEditor_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            MacOSCodeEditor(
                content: .constant("""
                {
                "h1": 1
                }
                """),
                language: .json,
                size: geometry.size
            )
        }
    }
}

#endif
