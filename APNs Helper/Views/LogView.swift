//
//  LogView.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI

/// 发送结果日志：只读输出。
///
/// 之前是可编辑的 `TextEditor`（用户能改日志、光标还会抢焦点），
/// 改为只读 `Text` + 可选中复制，并提供空状态提示与复制按钮。
struct LogView: View {

    @Environment(AppModel.self) private var appModel

    private var isEmpty: Bool { appModel.appLog.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.compact) {
            HStack {
                Text(Constants.log.value)
                Spacer()
                Button {
                    appModel.appLog.copyToPasteboard()
                } label: {
                    Label(Constants.copyLog.value, systemImage: "doc.on.doc")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
                .disabled(isEmpty)
                .accessibilityLabel(Text(Constants.copyLog.value))
                .help(Constants.copyLog.value)
            }

            ScrollView {
                Text(isEmpty ? Constants.logEmptyHint.value : appModel.appLog)
                    .font(Design.Typography.log)
                    .foregroundStyle(isEmpty ? AnyShapeStyle(.secondary) : AnyShapeStyle(.primary))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Design.Spacing.compact)
            }
            .frame(minHeight: Design.Metrics.logMinHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color.appEditorBackground,
                in: RoundedRectangle(cornerRadius: Design.Radius.editor, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Design.Radius.editor, style: .continuous)
                    .strokeBorder(Color.appSeparator, lineWidth: 1)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text(Constants.log.value))
        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            LogView()
                .padding()
                .previewDevice("My Mac")
                .previewDisplayName("MacOS")

            Form {
                Section(Constants.log.value) {
                    LogView()
                }
            }
            .previewDevice("iPhone 14 Pro Max")
            .previewDisplayName("iOS")
        }
        .environment(AppModel())
    }
}
