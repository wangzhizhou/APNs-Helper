//
//  MacOSCodeEditor.swift
//  APNs Helper
//
//  Created by joker on 2023/5/12.
//

#if os(macOS)

import AppKit
import SwiftUI
import Combine

struct MacOSCodeEditor: NSViewRepresentable {

    @Binding var content: String

    var language: CodeFomater.Language?

    let size: CGSize

    let colorScheme: ColorScheme

    var onError: ((Error?) -> Void)?

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
        textView.maxSize = NSSize(width: CGFloat.infinity, height: CGFloat.infinity)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.isAutomaticLinkDetectionEnabled = false
        textView.usesFontPanel = false
        textView.textContainer?.containerSize = textView.maxSize
        textView.textContainer?.widthTracksTextView = false

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        textView.defaultParagraphStyle = paragraphStyle
        textView.delegate = context.coordinator
        textView.allowsUndo = true
        textView.enabledTextCheckingTypes = 0

        scrollView.documentView = textView
        context.coordinator.scrollView = scrollView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        format(scrollView)
    }
    func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSScrollView, context: Context) -> CGSize? {
        return size
    }

    func format(_ scrollView: NSScrollView, force: Bool = false) {
        guard let textView = scrollView.textView
        else {
            return
        }
        do {
            guard !content.isEmpty
            else {
                if !textView.string.isEmpty {
                    textView.string = content
                }
                return
            }
            let newResult = try CodeFomater.format(
                content,
                cursorPosition: textView.selectedRange().location,
                language: language)
            guard let newString = newResult?.formattedString, let cursorPosition = newResult?.cursorOffset
            else {
                return
            }
            if let onError = onError {
                onError(nil)
            }
            if !force {
                guard textView.string != newString else {
                    return
                }
            }
            textView.string = newString
            textView.setSelectedRange(NSRange(location: cursorPosition, length: 0))
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

        var scrollView: NSScrollView?

        let textDidChangeSubject = PassthroughSubject<Void, Never>()

        var cancellables = [AnyCancellable]()

        init(parent: MacOSCodeEditor) {
            self.parent = parent
            super.init()
            let cancellable = textDidChangeSubject.debounce(for: 0.3, scheduler: RunLoop.main).sink {[weak self] _ in
                if let scrollView = self?.scrollView {
                    parent.format(scrollView, force: true)
                }
            }
            cancellables.append(cancellable)
        }
        func textDidChange(_ notification: Notification) {
            guard let text = notification.object as? NSText
            else {
                return
            }
            if parent.content != text.string {
                parent.content = text.string
                textDidChangeSubject.send()
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
