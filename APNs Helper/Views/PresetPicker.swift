//
//  PresetView.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI

struct PresetPicker: View {
    
    let presetAppInfos: [AppInfo]
    
    @Binding var selectedAppInfo: AppInfo
    
    var onPresetChange: (AppInfo) -> Void
    
    var body: some View {
        Picker(Constants.preset.value, selection: $selectedAppInfo) {
            ForEach(presetAppInfos, id: \.bundleID) {
                if $0.bundleID.isEmpty {
                    Text(Constants.presetnone.value)
                        .tag($0)
                } else {
                    Text($0.bundleID)
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
        .onChange(of: selectedAppInfo) { _, newValue in
            onPresetChange(newValue)
        }
    }
}
struct PresetView_Previews: PreviewProvider {
    static let presets: [AppInfo] = [.none, .test]
    static var previews: some View {
        Group {
            PresetPicker(presetAppInfos: presets, selectedAppInfo: .constant(.none)) { _ in
                
            }
            .frame(width: 300)
            .previewDevice("My Mac")
            .previewDisplayName("MacOS")
            
            Form {
                Section {
                    PresetPicker(presetAppInfos: presets, selectedAppInfo: .constant(.none)) { _ in
                    }
                }
            }
            .previewDevice("Phone 14 Pro Max")
            .previewDisplayName("iOS")
        }
        .padding()
    }
}
