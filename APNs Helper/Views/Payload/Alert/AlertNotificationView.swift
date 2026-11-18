//
//  AlertNotificationView.swift
//  APNs Helper
//
//  Created by joker on 10/28/23.
//

import SwiftUI

struct AlertNotificationView: View {

    @State var model = AlertModel()

    /// 传入时在底部显示「Use This Payload」，把结构化结果交回调用方（写入 Payload 编辑器）
    var onApply: ((String) -> Void)?

    
    var body: some View {
        
        VStack {
            
            // aps
            VStack {
                
                // alert
                VStack {
                    
                    InputView(
                        title: "Title",
                        placeholder: "Alert Title",
                        inputValue: $model.alertTitle
                    )
                    
                    InputView(
                        title: "Subtitle",
                        placeholder: "Alert Subtitle",
                        inputValue: $model.alertSubtitle
                    )
                    
                    InputView(
                        title: "Body",
                        placeholder: "Alert Body",
                        inputValue: $model.alertBody
                    )
                    
                    InputView(
                        title: "Launch Image",
                        placeholder: "Alert Launch Image",
                        inputValue: $model.alertLaunchImage
                    )
                }
                
                // badge
                InputView(
                    title: "Badge Number",
                    inputValue: $model.badge
                )
                
                // sound
                InputView(
                    title: "Sound",
                    inputValue: $model.sound
                )
                
                // threadID
                InputView(
                    title: "Thread ID",
                    inputValue: $model.threadID
                )
                
                // category
                InputView(
                    title: "Category",
                    inputValue: $model.category
                )
                
                // mutable content
                InputView(
                    title: "Mutable Content",
                    inputValue: $model.mutableContent
                )
                
                // target content ID
                InputView(
                    title: "Target ContentID",
                    inputValue: $model.targetContentID
                )
                
                // interruption level
                InputView(
                    title: "InterruptionLevel",
                    inputValue: $model.interruptionLevel
                )
                
                // relevance score
                InputView(
                    title: "Relevance Score",
                    inputValue: $model.relevanceScore
                )
                
            }
            
            // payload
            if let payloadEditorContent = model.payloadEditorContent {
                PayloadEditor(payload: .constant(payloadEditorContent))
                    .padding([.top], 10)
                    .frame(height: 200)
                    .disabled(true)

                if let onApply {
                    Button("Use This Payload") {
                        onApply(payloadEditorContent)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding([.top], 8)
                }
            }
        }
        .padding()
    }
}

#Preview("Simple Alert") {
    
    AlertNotificationView(
        model: AlertModel(
            alertTitle: "Simple Alert",
            alertSubtitle: "Subtitle",
            alertBody: "Body"
        )
    )
}

#Preview("Threaded Alert") {
    
    AlertNotificationView(
        model: AlertModel(
            alertTitle: "Threaded Alert",
            alertSubtitle: "Subtitle",
            alertBody: "Body",
            threadID: "threadID"
        )
    )
}

#Preview("Custom Category Alert") {
    
    AlertNotificationView(
        model: AlertModel(
            alertTitle: "Custom Category Alert",
            alertSubtitle: "Subtitle",
            alertBody: "Body",
            category: "Custom Category"
        )
    )
}

#Preview("Mutable Alert") {
    
    AlertNotificationView(
        model: AlertModel(
            alertTitle: "Mutable Alert",
            alertSubtitle: "Subtitle",
            alertBody: "Body",
            mutableContent: "1"
        )
    )
}
