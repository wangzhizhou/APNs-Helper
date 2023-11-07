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
        
        Text("LiveActivityContentView: \(contenxt.state.stage.rawValue)")
    }
}
#endif
