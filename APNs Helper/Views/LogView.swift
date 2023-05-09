//
//  LogView.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI

struct LogView: View {
    
    @EnvironmentObject var appModel: AppModel
    
    @FocusState
    private var logTextEditorFocusState: Bool
    
    var body: some View {
#if os(macOS)
        InputTextEditor(title: Constants.log.value, content: $appModel.appLog)
            .frame(minHeight: 100)
#elseif os(iOS)
        InputTextEditor(content: $appModel.appLog, textEditorFont: .system(size: 9))
            .focused($logTextEditorFocusState)
            .onChange(of: logTextEditorFocusState, perform: { focusState in
                guard focusState == false
                else {
                    logTextEditorFocusState = false
                    return
                }
            })
            .frame(height: 100)
            .padding(.vertical, 5)
#endif
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
        .environmentObject(AppModel())
    }
}
