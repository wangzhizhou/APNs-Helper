//
//  ContentView.swift
//  APNs Helper
//
//  Created by joker on 2024/4/29.
//

import SwiftUI

enum SelectionType: String, CaseIterable {
    case alert
    case background
    case voip
    case fileprovider
    case location
    case liveactivity
}

enum EnvironmentType: String, CaseIterable {
    case development
    case production
}

enum SendResult {
    case noop
    case success
    case failure(error: SendResultError)

    var systemImageName: String {
        switch self {
        case .noop:
            return ""
        case .success:
            return "checkmark.seal.fill"
        case .failure:
            return "xmark.diamond.fill"
        }
    }
}

enum SendResultError: Error {
    case network
}

struct ContentView: View {
    @State private var input: String = ""
    @State private var selection: SelectionType = .alert
    @State private var environment: EnvironmentType = .development
    @State private var preset: String = "App1"
    @State private var payload: String = "{\"hello\": \"value\"}"
    @State private var sendResult: SendResult = .failure(error: .network)
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .content
    @State private var fillThisAppInfo: Bool = false
    @State private var logReadOnlyEditorContent: String = "Log Content"
    var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            preferredCompactColumn: $preferredCompactColumn) {
                Text("SideBar")
                    .toolbar(removing: .sidebarToggle)
            } content: {
                Form {
                    Section {
                        HStack {
                            Picker("Presets", selection: $preset) {
                                ForEach(["App1", "App2"], id: \.self) { preset in
                                    Text(preset).tag(preset)
                                }
                            }
                            Spacer()
                            Button("Clear All Presets") {

                            }
                        }
                    }
                    Section {
                        Picker("Type", selection: $selection) {
                            ForEach(SelectionType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                                    .tag(type)
                            }
                        }
                        Picker("Env", selection: $environment) {
                            ForEach(EnvironmentType.allCases, id: \.self) { environment in
                                Text(environment.rawValue)
                                    .tag(environment)
                            }
                        }
                    }
                    Section {
                        TextField("Key ID", text: $input)
                        TextField("Team ID", text: $input)
                        TextField("Bundle ID", text: $input)
                        VStack {
                            HStack {
                                Text("P8 Key")
                                Spacer()
                                Button("Import P8") {
                                }
                            }
                            TextField("", text: $input)
                        }
                        TextField("Device Token", text: $input)
                        HStack {
                            Toggle("Fill This App's Info", isOn: $fillThisAppInfo)
                            Button("Save as Preset") {

                            }
                            Button("Import From Pasteboard") {

                            }
                            Button("Remove From Preset") {

                            }
                        }
                    }

                    Section("Log") {
                        TextEditor(text: $logReadOnlyEditorContent)
                    }
                }
                .formStyle(GroupedFormStyle())
                .toolbar {
                    ToolbarItem {
                        Button {

                        } label: {
                            HStack {
                                Text("Send")
                                    .bold()
                                Image(systemName: sendResult.systemImageName)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(height: 15)
                            }
                        }
                    }
                }
                .navigationSplitViewColumnWidth(min: 300, ideal: 500)

            } detail: {
                PayloadEditor(payload: $payload)
            }
            .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    ContentView()
}
