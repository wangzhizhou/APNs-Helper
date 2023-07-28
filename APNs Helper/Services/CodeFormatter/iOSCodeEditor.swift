//
//  IOSCodeEditor.swift
//  APNs Helper
//
//  Created by joker on 2023/5/12.
//

#if os(iOS)

import UIKit
import SwiftUI
import Combine

struct IOSCodeEditor: UIViewRepresentable {

    @EnvironmentObject var appModel: AppModel

    @Binding var content: String

    var language: CodeFomater.Language?

    let size: CGSize

    let colorScheme: ColorScheme

    var onError: ((Error?) -> Void)?

    func makeUIView(context: Context) -> UITextView {
        CodeFomater.resetTheme(colorScheme: colorScheme)
        let frame = CGRect(origin: .zero, size: size)
        let textView = UITextView(frame: frame, textContainer: CodeFomater.highlightTextContainer(language: language))
        textView.delegate = context.coordinator
        textView.autocorrectionType = .no
        textView.smartQuotesType = .no
        textView.backgroundColor = .clear

        context.coordinator.textView = textView
        return textView
    }

    // swiftlint: disable cyclomatic_complexity
    func format(_ textView: UITextView, force: Bool = false) {
        do {
            if !textView.text.isEmpty {
                guard let runloopMode = RunLoop.main.currentMode, runloopMode != .tracking
                else {
                    return
                }
            }
            guard !textView.isDragging, !textView.isTracking, !textView.isDecelerating
            else {
                return
            }
            guard !content.isEmpty
            else {
                if !textView.text.isEmpty {
                    textView.text = content
                }
                return
            }
            let newResult = try CodeFomater.format(
                content,
                cursorPosition: textView.selectedRange.location,
                language: language)
            guard let newText = newResult?.formattedString, let cursorPosition = newResult?.cursorOffset
            else {
                return
            }
            if let onError = onError {
                onError(nil)
            }
            if !force {
                guard textView.text != newText else {
                    return
                }
            }
            textView.text = newText
            textView.selectedRange = NSRange(location: cursorPosition, length: 0)
        } catch let error {
            if let onError = onError {
                onError(error)
            }
        }
    }
    // swiftlint: enable cyclomatic_complexity

    func updateUIView(_ textView: UITextView, context: Context) {
        format(textView)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {

        let parent: IOSCodeEditor

        var textView: UITextView?

        let textDidChangeSubject = PassthroughSubject<Void, Never>()

        var cancellables = [AnyCancellable]()

        init(parent: IOSCodeEditor) {
            self.parent = parent
            super.init()
            let cancellable = textDidChangeSubject.debounce(for: 0.3, scheduler: RunLoop.main).sink {[weak self] _ in
                if let textView = self?.textView {
                    parent.format(textView, force: true)
                }
            }
            cancellables.append(cancellable)
        }

        func textViewDidChange(_ textView: UITextView) {
            guard parent.content != textView.text else {
                return
            }
            parent.content = textView.text
            textDidChangeSubject.send()
        }
    }
}

struct IOSCodeEditor_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in

            IOSCodeEditor(
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
