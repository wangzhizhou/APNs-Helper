//
//  AlertNotificationView.swift
//  APNs Helper
//
//  Created by joker on 10/28/23.
//

import SwiftUI

struct AlertNotificationView: View {
    
    @State var model = AlertModel()
    
    private let titleWidth: CGFloat = 120
    
    var body: some View {
        
        VStack {
            
            // aps
            VStack {
                
                // alert
                VStack {
                    
                    InputView(
                        title: "Title",
                        placeholder: "Alert Title",
                        titleWidth: titleWidth,
                        inputValue: $model.alertTitle
                    )
                    
                    InputView(
                        title: "Subtitle",
                        placeholder: "Alert Subtitle",
                        titleWidth: titleWidth,
                        inputValue: $model.alertSubtitle
                    )
                    
                    InputView(
                        title: "Body",
                        placeholder: "Alert Body",
                        titleWidth: titleWidth,
                        inputValue: $model.alertBody
                    )
                    
                    InputView(
                        title: "Launch Image",
                        placeholder: "Alert Launch Image",
                        titleWidth: titleWidth,
                        inputValue: $model.alertLaunchImage
                    )
                }
                
                // badge
                InputView(
                    title: "Badge Number",
                    titleWidth: titleWidth,
                    inputValue: $model.badge
                )
                
                // sound
                InputView(
                    title: "Sound",
                    titleWidth: titleWidth,
                    inputValue: $model.sound
                )
                
                // threadID
                InputView(
                    title: "Thread ID",
                    titleWidth: titleWidth,
                    inputValue: $model.threadID
                )
                
                // category
                InputView(
                    title: "Category",
                    titleWidth: titleWidth,
                    inputValue: $model.category
                )
                
                // mutable content
                InputView(
                    title: "Mutable Content",
                    titleWidth: titleWidth,
                    inputValue: $model.mutableContent
                )
                
                // target content ID
                InputView(
                    title: "Target ContentID",
                    titleWidth: titleWidth,
                    inputValue: $model.targetContentID
                )
                
                // interruption level
                InputView(
                    title: "InterruptionLevel",
                    titleWidth: titleWidth,
                    inputValue: $model.interruptionLevel
                )
                
                // relevance score
                InputView(
                    title: "Relevance Score",
                    titleWidth: titleWidth,
                    inputValue: $model.relevanceScore
                )
                
            }
            
            // payload
            if let payloadEditorContent = model.payloadEditorContent {
                PayloadEditor(payload: .constant(payloadEditorContent))
                    .padding([.top], 10)
                    .frame(height: 200)
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
