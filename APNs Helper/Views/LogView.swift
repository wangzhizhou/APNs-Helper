//
//  LogView.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI

struct LogView: View {

    @Environment(AppModel.self) private var appModel

    @FocusState
    private var logTextEditorFocusState: Bool

    var body: some View {
        @Bindable var appModel = appModel
        VStack {
#if os(macOS)
            InputTextEditor(title: Constants.log.value, content: $appModel.appLog)
                .frame(minHeight: 100)
#elseif os(iOS)
            InputTextEditor(content: $appModel.appLog, textEditorFont: .system(size: 9))
                .frame(height: 100)
                .padding(.vertical, 5)
#endif
        }
        .focused($logTextEditorFocusState)
        .onChange(of: logTextEditorFocusState) { _, newValue in
            guard newValue == false
            else {
                logTextEditorFocusState = false
                return
            }
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
