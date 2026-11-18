//
//  InputTextEditor.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import SwiftUI

/// 多行文本编辑器（P8 Key 等）。
///
/// 字号改用语义文本样式 + 等宽设计，跟随 Dynamic Type；
/// 容器统一由 `textContainer()` 提供语义背景与描边。
struct InputTextEditor: View {

    var title: String?

    @Binding var content: String

    var body: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.compact) {
            if let title = title {
                Text(title)
            }
            TextEditor(text: $content)
                .scrollContentBackground(.hidden)
                .font(Design.Typography.code)
                .autocorrectionDisabled()
#if os(iOS)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.never)
#endif
                .textContainer()
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
