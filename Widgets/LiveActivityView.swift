//
//  LiveActivityView.swift
//  WidgetsExtension
//
//  Created by joker on 11/7/23.
//

#if canImport(WidgetKit) && os(iOS)
import SwiftUI
import WidgetKit

struct LiveActivityView: View {

    let contenxt: ActivityViewContext<LiveActivityAttributes>
    
    var body: some View {
        
        let randomColor = Color.random
        Text(Date().formatted(.dateTime.year().month().day().hour().minute().second()))
            .foregroundStyle(randomColor)
            .font(.subheadline)
            .padding()
            .background(randomColor.colorInvert())
            
    }
}
#endif
