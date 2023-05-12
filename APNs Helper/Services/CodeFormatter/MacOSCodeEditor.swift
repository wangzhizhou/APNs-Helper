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
    
    let colorScheme: ColorScheme
    
    var onError: ((Error?) -> Void)? = nil
    
    func makeNSView(context: Context) -> NSScrollView {
        CodeFomater.resetTheme(colorScheme: colorScheme)
        let frame = CGRect(origin: .zero, size: size)
        
        let scrollView = NSTextView.scrollableTextView()
        scrollView.frame = frame
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        scrollView.horizontalScrollElasticity = .none
        
        let highlighter = CodeFomater.highlightTextContainer(language: language)
        let textView = NSTextView(frame: frame, textContainer: highlighter)
        textView.drawsBackground = false
        textView.minSize = size
        textView.maxSize = NSSize(width: size.width, height: CGFloat.infinity)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.usesFontPanel = false
        textView.textContainer?.containerSize = textView.maxSize
        textView.textContainer?.widthTracksTextView = true
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        textView.defaultParagraphStyle = paragraphStyle
        textView.delegate = context.coordinator
        textView.allowsUndo = true
        textView.enabledTextCheckingTypes = 0
        
        scrollView.documentView = textView
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        format(scrollView)
    }
    func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSScrollView, context: Context) -> CGSize? {
        return size
    }
    
    func format(_ scrollView: NSScrollView) {
        
        guard let textView = scrollView.textView
        else {
            return
        }
        
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
            textView.layer?.borderColor = NSColor.red.cgColor
            if let onError = onError {
                onError(error)
            }
        }
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
            guard let text = notification.object as? NSText
            else {
                return
            }
            if parent.content != text.string {
                parent.content = text.string
            }
        }
    }
}

extension NSScrollView {
    var textView: NSTextView? {
        guard let textView = self.documentView as? NSTextView
        else {
            return nil
        }
        return textView
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
                size: geometry.size,
                colorScheme: .light
            )
        }
    }
}
#endif
