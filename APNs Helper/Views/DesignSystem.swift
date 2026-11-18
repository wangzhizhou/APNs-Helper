//
//  DesignSystem.swift
//  APNs Helper
//
//  设计令牌：间距、圆角、排版、容器样式统一收敛在这里。
//  字号一律用语义文本样式（.footnote / .caption）而不是固定 pt，以跟随 Dynamic Type。
//

import SwiftUI

enum Design {

    /// 间距梯度：紧凑（图标与文本）、常规（字段内）、区块（Section 之间）
    enum Spacing {
        static let compact: CGFloat = 6
        static let regular: CGFloat = 12
        static let section: CGFloat = 20
    }

    enum Radius {
        static let editor: CGFloat = 8
    }

    /// payload / token / 日志这类机器可读文本用等宽字体，并与正文同样支持 Dynamic Type
    enum Typography {
        static let code: Font = .system(.footnote, design: .monospaced)
        static let log: Font = .system(.caption, design: .monospaced)
        static let field: Font = .system(.body, design: .monospaced)
        static let hint: Font = .footnote
    }

    /// 内容区高度：payload 编辑器给固定高度（内部是滚动视图），日志区给最小高度
    enum Metrics {
        static let payloadHeight: CGFloat = 200
        static let logMinHeight: CGFloat = 110
    }
}

extension Color {

    /// 分隔线：用系统语义色，自动适配亮/暗、高对比度与减少透明度
#if os(iOS)
    static let appSeparator = Color(uiColor: .separator)
    static let appEditorBackground = Color(uiColor: .secondarySystemBackground)
#elseif os(macOS)
    static let appSeparator = Color(nsColor: .separatorColor)
    static let appEditorBackground = Color(nsColor: .textBackgroundColor)
#endif
}

extension View {

    /// 代码编辑器、日志等文本容器的统一外观
    func textContainer() -> some View {
        self
            .padding(Design.Spacing.compact)
            .background(
                Color.appEditorBackground,
                in: RoundedRectangle(cornerRadius: Design.Radius.editor, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Design.Radius.editor, style: .continuous)
                    .strokeBorder(Color.appSeparator, lineWidth: 1)
            }
    }
}
