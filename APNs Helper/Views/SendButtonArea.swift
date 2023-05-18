//
//  SendButtonArea.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI

struct SendButtonArea: View {
    
    @EnvironmentObject var appModel: AppModel
    
    @EnvironmentObject var contentModel: AppContentModel
    
    let loadPayloadTemplate: () -> Void
    
    private var myLayout: AnyLayout {
#if os(iOS)
        AnyLayout(VStackLayout())
#elseif os(macOS)
        AnyLayout(HStackLayout())
#endif
    }
    
    var body: some View {
        myLayout {
            
#if os(macOS)
            if contentModel.payload.isEmpty {
                Button(Constants.loadTemplate.value, action: loadPayloadTemplate)
                    .disabled(appModel.isSendingPush)
                    .keyboardShortcut(.init(unicodeScalarLiteral: Constants.loadTemplateShortcutKey.firstChar), modifiers: [.command])
            }
#endif
            
            Button {
                let (ready, message) = contentModel.config.isReadyForSend
                guard ready else {
                    if let message = message {
                        appModel.toastModel = ToastModel.info().title("\(message) is not ready")
                    }
                    return
                }
                
                let config = contentModel.config
                Task {
                    guard !contentModel.payload.isEmpty
                    else {
                        appModel.toastModel = ToastModel.info().title("\(Constants.payload.value) is Empty")
                        return
                    }
                    appModel.isSendingPush = true
                    appModel.resetLog()
                    if let payloadData = contentModel.payload.data(using: .utf8) {
                        _ = try? await APNsService(config: config, payloadData: payloadData, appModel: appModel).send()
                    }
                    appModel.isSendingPush = false
                }
            } label: {
#if os(iOS)
                GeometryReader { geometry in
                    HStack {
                        if appModel.isSendingPush {
                            ProgressView()
                                .tint(Color.orange)
                                .padding([.trailing], 1)
                        }
                        Text(appModel.isSendingPush ? Constants.sending.value : Constants.sendPush.value)
                            .bold()
                            .font(.title3)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
#elseif os(macOS)
                Text(appModel.isSendingPush ? Constants.sending.value : Constants.send.value)
#endif
            }
        }
        .disabled(appModel.isSendingPush)
#if os(iOS)
        .frame(height: 50)
        .buttonStyle(BorderedProminentButtonStyle())
#elseif os(macOS)
        .keyboardShortcut(.return, modifiers: [.command])
#endif
    }
}

struct SendButtonArea_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            SendButtonArea(loadPayloadTemplate: {
                
            })
            .previewDevice("My Mac")
            .previewDisplayName("MacOS")
            
            SendButtonArea(loadPayloadTemplate: {
                
            })
            .previewDevice("iPhone 14 Pro Max")
            .previewDisplayName("iOS")
        }
        .padding()
        .environmentObject(AppModel())
        .environmentObject(AppContentModel())
    }
}
