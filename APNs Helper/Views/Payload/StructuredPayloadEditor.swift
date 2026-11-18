//
//  StructuredPayloadEditor.swift
//  APNs Helper
//
//  Created by joker on 2025/11/18.
//

import SwiftUI

/// 结构化 Payload 构造入口。
///
/// alert / live activity 已经有完整的表单式编辑器（`AlertNotificationView` /
/// `LiveActivityNotificationView`），但之前只在 Preview 里被引用，用户进不去。
/// 这里把它们接进主流程：填完表单点「Use This Payload」写回 JSON 编辑器。
struct StructuredPayloadEditor: View {

    let pushType: PushType
    let onApply: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                content
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 520, minHeight: 620)
#endif
    }

    @ViewBuilder
    private var content: some View {
        switch pushType {
        case .alert:
            AlertNotificationView { payload in
                onApply(payload)
                dismiss()
            }
        case .liveactivity:
            LiveActivityNotificationView { payload in
                onApply(payload)
                dismiss()
            }
        default:
            Text("Structured editing is not available for this push type.")
                .foregroundStyle(.secondary)
                .padding()
        }
    }

    private var title: String {
        "Structured Payload · \(pushType.rawValue)"
    }
}
