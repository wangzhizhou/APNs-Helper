//
//  PayloadEditor.swift
//  APNs Helper
//
//  Created by joker on 2023/5/12.
//

import SwiftUI

struct PayloadEditor: View {

    @Environment(AppModel.self) private var appModel

    var title: String?

    @Binding var payload: String

    @State private var hasError: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.compact) {
            HStack(spacing: Design.Spacing.compact) {
                if let title = title {
                    Text(title)
                }
                Spacer()
                if hasError {
                    Label(Constants.invalidPayload.value, systemImage: "exclamationmark.triangle.fill")
                        .font(Design.Typography.hint)
                        .foregroundStyle(.red)
                        .accessibilityLabel(Text(Constants.invalidPayload.value))
                }
            }

            CodeEditor(content: $payload) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        hasError = true
                        appModel.appLog = error.localizedDescription
                    } else if hasError {
                        hasError = false
                        appModel.resetLog()
                    }
                }
            }
            .textContainer()
        }
    }
}

struct PayloadEditor_Previews: PreviewProvider {
    static var previews: some View {
        PayloadEditor(
            payload: .constant("""
            {
            "aps": {
            "title": "title content"
            }
            }
            """))
    }
}
