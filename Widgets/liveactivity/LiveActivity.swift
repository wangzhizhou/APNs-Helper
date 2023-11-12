//
//  LiveActivity.swift
//  APNs Helper
//
//  Created by joker on 11/6/23.
//

#if canImport(WidgetKit) && os(iOS)
import WidgetKit
import SwiftUI

struct LiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        
        return ActivityConfiguration(for: LiveActivityAttributes.self) { _ in
            Text(Date().formatted(.dateTime.year().month().day().hour().minute().second()))
                .foregroundStyle(.primary)
                .activityBackgroundTint(.random)
        } dynamicIsland: { _ in
            
            DynamicIsland(expanded: {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("Center")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                }
            }, compactLeading: {
                Text("Leading")
            }, compactTrailing: {
                Text("Trailing")
            }, minimal: {
                Text("😅")
            })
            .keylineTint(.teal)
        }
    }
}

#Preview("Live Activity", as: .content, using: LiveActivityAttributes(), widget: {
    LiveActivity()
}, contentStates: {
    LiveActivityContentState()
})

#endif
