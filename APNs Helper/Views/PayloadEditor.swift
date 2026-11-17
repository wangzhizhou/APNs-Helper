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

    @State var hasError: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            if let title = title {
                Text(title)
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
            .editorBorder()
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
