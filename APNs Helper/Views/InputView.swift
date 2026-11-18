//
//  InputView.swift
//  APNs Helper
//
//  Created by joker on 2022/9/28.
//

import SwiftUI

/// 单行输入行（KeyID / TeamID / BundleID / 各类 token）。
///
/// 用 `LabeledContent` 而不是手写 HStack + 固定 labelWidth：
/// - 标签与输入框在 `Form` 里自动对齐，不再依赖魔法宽度
/// - 字号跟随 Dynamic Type，大字号下不会被截断
/// - 标签对 VoiceOver 是字段名，图标按钮补充显式 accessibilityLabel
struct InputView: View {

    let title: String

    var placeholder: String?

    @Binding var inputValue: String

    @FocusState private var isFocused: Bool

    var body: some View {
        LabeledContent {
            HStack(spacing: Design.Spacing.compact) {
                // 标签已在 LabeledContent 左侧，字段内不再重复显示占位标题
                Spacer(minLength: 0)
                TextField(placeholder ?? "", text: $inputValue)
                    .labelsHidden()
                    .accessibilityLabel(Text(title))
                    .frame(maxWidth: 320)
                    .font(Design.Typography.field)
                    .focused($isFocused)
                    .onSubmit { isFocused = false }
                    .onChange(of: inputValue) { _, newValue in
                        let trimmedValue = newValue.replacingOccurrences(of: " ", with: "")
                        guard trimmedValue == newValue else {
                            inputValue = trimmedValue
                            return
                        }
                    }
#if os(iOS)
                    .keyboardType(.asciiCapable)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .textFieldStyle(.plain)
#elseif os(macOS)
                    .textFieldStyle(.roundedBorder)
#endif

                if !inputValue.isEmpty {
                    Button {
                        inputValue = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.tertiary)
                    .accessibilityLabel(Text("Clear \(title)"))

                    Button {
                        inputValue.copyToPasteboard()
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(Text("Copy \(title)"))
                }
            }
        } label: {
            Text(title)
        }
    }
}

struct InputView_Previews: PreviewProvider {

    @State static var value: String = ""

    static var previews: some View {
        Group {
            Form {
                InputView(title: Constants.keyid.value, inputValue: $value)
                InputView(title: Constants.teamid.value, inputValue: $value)
                InputView(title: Constants.bundleid.value, inputValue: $value)
            }
            .formStyle(.grouped)
            .previewDevice("My Mac")
            .previewDisplayName("MacOS")

            Form {
                InputView(title: Constants.keyid.value, inputValue: $value)
                InputView(title: Constants.teamid.value, inputValue: $value)
                InputView(title: Constants.bundleid.value, inputValue: $value)
            }
            .previewDevice("iPhone 14 Pro Max")
            .previewDisplayName("iOS")
        }
    }
}
