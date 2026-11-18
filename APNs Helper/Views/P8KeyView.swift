//
//  P8KeyView.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI
import UniformTypeIdentifiers

struct P8KeyView: View {

    @Binding var showFileImporter: Bool

    @Binding var privateKey: String

    var editorHeight: CGFloat = 80.0

    var onPrivateKeyChange: ((String) -> Void)?

    var onFileImporterError: ((Error) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.compact) {
            HStack {
                Text(Constants.p8key.value)
                Spacer()
                Button {
                    showFileImporter = true
                } label: {
                    Label(Constants.importP8File.value, systemImage: "doc.badge.plus")
                }
                .buttonStyle(.borderless)
                .help("Choose a .p8 key file from disk")
            }

            InputTextEditor(content: $privateKey)
                .scrollIndicators(.hidden)
                .frame(height: editorHeight)
                // .p8 是签名凭据：截图与录屏时由系统打码
                .privacySensitive()
                .onChange(of: privateKey) { _, newValue in
                    if let onPrivateKeyChange = onPrivateKeyChange {
                        onPrivateKeyChange(newValue)
                    }
                }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [UTType(filenameExtension: Constants.p8FileExt.value)!]) { result in
            switch result {
            case .success(let url):
                if let output = url.p8FileContent {
                    privateKey = output
                }
            case .failure(let error):
                if let onFileImporterError = onFileImporterError {
                    onFileImporterError(error)
                }
            }
        }
    }
}

struct P8KeyView_Previews: PreviewProvider {

    @State static var showFileImporter: Bool = false
    @State static var privateKey: String = ""

    static var previews: some View {
        Group {
            P8KeyView(
                showFileImporter: $showFileImporter,
                privateKey: $privateKey)
            .padding()
            .previewDevice("My Mac")
            .previewDisplayName("MacOS")

            Form {
                Section {
                    P8KeyView(
                        showFileImporter: $showFileImporter,
                        privateKey: $privateKey)
                }
            }
            .previewDevice("iPhone 14 Pro Max")
            .previewDisplayName("iOS")
        }
    }
}
