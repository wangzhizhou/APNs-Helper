//
//  PresetView.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI

struct PresetPicker: View {

    let presets: [Config]

    @Binding var selectedPreset: Config

    var onPresetChange: (Config) -> Void

    var body: some View {
        Picker(Constants.preset.value, selection: $selectedPreset) {
            ForEach(presets) {
                if $0 == .none {
                    Text(Constants.presetnone.value)
                        .tag($0)
                } else {
                    Text($0.appBundleID)
                        .lineLimit(1)
                        .tag($0)
                }
            }
        }
#if os(iOS)
        .pickerStyle(.inline)
#elseif os(macOS)
        .padding(.vertical)
#endif
        .onChange(of: selectedPreset) { _, newValue in
            onPresetChange(newValue)
        }
    }
}
struct PresetView_Previews: PreviewProvider {
    static let presets: [Config] = [
        .none,
        .init(
            deviceToken: "test device token",
            pushKitVoIPToken: "test pushkit token",
            pushKitFileProviderToken: "test file provider token",
            locationPushServiceToken: "test location push service token",
            liveActivityPushToken: "test live activity push token",
            appBundleID: "test aid",
            privateKey: "test private key",
            keyIdentifier: "test key id",
            teamIdentifier: "test team id")
    ]
    static var previews: some View {
        Group {
            PresetPicker(presets: presets, selectedPreset: .constant(.none)) { _ in

            }
            .frame(width: 300)
            .previewDevice("My Mac")
            .previewDisplayName("MacOS")

            Form {
                Section {
                    PresetPicker(presets: presets, selectedPreset: .constant(.none)) { _ in
                    }
                }
            }
            .previewDevice("Phone 14 Pro Max")
            .previewDisplayName("iOS")
        }
        .padding()
    }
}
