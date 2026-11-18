//
//  SendButtonArea.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI

/// 主操作区：发送推送。
///
/// - iOS：等宽的大号强调按钮（HIG 的主操作样式），发送中换成进度指示
/// - macOS：保留 ⌘↩ 快捷键，并补 `.help` 说明，避免快捷键只写在标题里
struct SendButtonArea: View {

    @Environment(AppModel.self) private var appModel

    @Environment(AppContentModel.self) private var contentModel

    let loadPayloadTemplate: () -> Void

    private var isSending: Bool { appModel.isSendingPush }

    var body: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.compact) {
            if let reason = blockingReason {
                Label(reason, systemImage: "info.circle")
                    .font(Design.Typography.hint)
                    .foregroundStyle(.secondary)
            }

            layout {
#if os(macOS)
                if contentModel.payload.isEmpty {
                    Button(Constants.loadTemplate.value) {
                        loadPayloadTemplate()
                    }
                    .disabled(isSending)
                    .keyboardShortcut(.init(unicodeScalarLiteral: Constants.loadTemplateShortcutKey.firstChar), modifiers: [.command])
                    .help("Load the template payload for the selected push type (⌘T)")
                }
#endif

                Button {
                    send()
                } label: {
                    HStack(spacing: Design.Spacing.compact) {
                        if isSending {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                                .accessibilityHidden(true)
                        }
                        Text(isSending ? Constants.sending.value : sendTitle)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isSending)
#if os(macOS)
                .keyboardShortcut(.return, modifiers: [.command])
                .help("Send the push notification (⌘↩)")
                .fixedSize()
#endif
            }
        }
#if os(iOS)
        .frame(maxWidth: .infinity)
#elseif os(macOS)
        .frame(maxWidth: .infinity, alignment: .trailing)
#endif
    }

    private var sendTitle: String {
#if os(iOS)
        Constants.sendPush.value
#elseif os(macOS)
        Constants.send.value
#endif
    }

    private var layout: AnyLayout {
#if os(iOS)
        AnyLayout(VStackLayout(spacing: Design.Spacing.compact))
#elseif os(macOS)
        AnyLayout(HStackLayout(spacing: Design.Spacing.regular))
#endif
    }

    /// 让「为什么点不了」直接显示在按钮旁，而不是只弹一个一闪而过的 toast
    private var blockingReason: String? {
        guard !contentModel.payload.isEmpty else { return nil }
        let (ready, message) = contentModel.config.isReadyForSend
        guard !ready, let message = message else { return nil }
        return "\(message) is not ready"
    }

    private func send() {
        let (ready, message) = contentModel.config.isReadyForSend
        guard ready else {
            if let message = message {
                appModel.toastModel = ToastModel.info().title("\(message) is not ready")
            }
            return
        }

        guard !contentModel.payload.isEmpty else {
            appModel.toastModel = ToastModel.info().title("\(Constants.payload.value) is Empty")
            return
        }

        let config = contentModel.config
        Task {
            appModel.isSendingPush = true
            // 无论成功、失败还是任务被取消，都必须复位，否则按钮会一直处于禁用状态
            defer { appModel.isSendingPush = false }
            appModel.resetLog()
            guard let payloadData = contentModel.payload.data(using: .utf8)
            else { return }
            _ = try? await APNsService(config: config, payloadData: payloadData, appModel: appModel).send()
        }
    }
}

struct SendButtonArea_Previews: PreviewProvider {
    static var previews: some View {
        Group {

            SendButtonArea { }
            .padding()
            .previewDevice("My Mac")
            .previewDisplayName("MacOS")

            SendButtonArea { }
            .padding()
            .previewDevice("iPhone 14 Pro Max")
            .previewDisplayName("iOS")
        }
        .environment(AppModel())
        .environment(AppContentModel())
    }
}
