//
//  DeveloperKeyView.swift
//  APNs Helper
//
//  自收发自测（Fill this App's Info）需要本 App 自己的 .p8 私钥。
//  仓库与构建产物都不含私钥，所以这里提供一次性的本机录入入口：存 Keychain。
//

import SwiftUI

struct DeveloperKeyView: View {

    /// 保存成功或清除后回调，让上层刷新 `thisAppConfig`
    var onChanged: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var keyIdentifier: String = DevSecrets.keyIdentifier
    @State private var teamIdentifier: String = DevSecrets.teamIdentifier
    @State private var privateKey: String = DevSecrets.privateKey
    @State private var showFileImporter = false
    @State private var errorMessage: String?
    @State private var saveFailed = false

    private var isConfigured: Bool { DevSecrets.isConfigured }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Key ID") {
                        TextField("10 characters", text: $keyIdentifier)
                            .labelsHidden()
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 220)
                            .autocorrectionDisabled()
#if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.asciiCapable)
#endif
                    }

                    LabeledContent("Team ID") {
                        TextField("10 characters", text: $teamIdentifier)
                            .labelsHidden()
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 220)
                            .autocorrectionDisabled()
#if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.asciiCapable)
#endif
                    }
                } header: {
                    Text("Credentials")
                } footer: {
                    Text("Key ID and Team ID are public; the .p8 below is the secret that signs the JWT.")
                }

                Section {
                    P8KeyView(
                        showFileImporter: $showFileImporter,
                        privateKey: $privateKey,
                        editorHeight: 120
                    )

                    if !privateKey.isEmpty {
                        Button("Remove Key", role: .destructive) {
                            privateKey = .empty
                        }
                    }
                } header: {
                    Text("APNs Auth Key (.p8)")
                } footer: {
                    Text("Stored in the Keychain on this device only — never in the repository or the app bundle.")
                }

                if let errorMessage = errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .font(Design.Typography.hint)
                    }
                }

                if isConfigured {
                    Section {
                        Button("Forget Saved Credentials", role: .destructive) {
                            DevSecrets.clear()
                            privateKey = .empty
                            keyIdentifier = DevSecrets.keyIdentifier
                            teamIdentifier = DevSecrets.teamIdentifier
                            onChanged()
                            dismiss()
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Self-Test Credentials")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(DevSecrets.validationError(
                            keyIdentifier: keyIdentifier,
                            teamIdentifier: teamIdentifier,
                            privateKey: privateKey
                        ) != nil)
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 560, minHeight: 520)
#endif
        .alert("Could not save to the Keychain", isPresented: $saveFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }

    private func save() {
        if let error = DevSecrets.validationError(
            keyIdentifier: keyIdentifier,
            teamIdentifier: teamIdentifier,
            privateKey: privateKey
        ) {
            errorMessage = error
            return
        }

        do {
            try DevSecrets.save(
                keyIdentifier: keyIdentifier,
                teamIdentifier: teamIdentifier,
                privateKey: privateKey
            )
            errorMessage = nil
            onChanged()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            saveFailed = true
        }
    }
}

/// 「Self-Test Credentials…」入口：显示当前是否已在本机配置过 .p8
struct SelfTestCredentialsButton: View {

    @Environment(AppModel.self) private var appModel

    @Environment(AppContentModel.self) private var contentModel

    private var isConfigured: Bool {
        !appModel.thisAppConfig.privateKey.trimmed.isEmpty
    }

    var body: some View {
        Button {
            contentModel.showDeveloperKeyEditor = true
        } label: {
            Label(
                Constants.selfTestCredentials.value,
                systemImage: isConfigured ? "checkmark.seal" : "key"
            )
        }
        .help(isConfigured ? Constants.selfTestKeySet.value : Constants.selfTestKeyMissing.value)
        .accessibilityHint(Text(isConfigured ? Constants.selfTestKeySet.value : Constants.selfTestKeyMissing.value))
    }
}

struct DeveloperKeyView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperKeyView {}
    }
}
