//
//  LiveActivityNotificationView.swift
//  APNs Helper
//
//  Created by joker on 10/29/23.
//

import SwiftUI

struct LiveActivityNotificationView: View {
    
    @State var model = LiveActivityModel()
    
    private let titleWidth: CGFloat = 120
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                InputView(
                    title: "timestamp",
                    placeholder: "timestamp",
                    titleWidth: titleWidth,
                    inputValue: $model.timestamp
                )
                
                Spacer(minLength: 50)
                
                Picker("event", selection: $model.event) {
                    ForEach(LiveActivityModel.Event.allCases) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
                .frame(width: 120)
            }

            InputView(
                title: "dismissal",
                placeholder: "dismissal",
                titleWidth: titleWidth,
                inputValue: $model.dismissal
            )
            
            VStack(alignment: .leading) {
                Text("content state")
                PayloadEditor(payload: $model.contentState)
                    .frame(minHeight: 100)
            }
            .padding(.vertical)
            
            
            if let payloadEditorContent = model.payloadEditorContent {
                PayloadEditor(payload: .constant(payloadEditorContent))
                    .frame(minHeight: 200)
                    .padding([.top], 10)
            }
        }
        .padding()
    }
}

#Preview {
    LiveActivityNotificationView()
}
