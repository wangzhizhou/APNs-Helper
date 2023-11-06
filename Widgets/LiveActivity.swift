//
//  LiveActivity.swift
//  APNs Helper
//
//  Created by joker on 11/6/23.
//

import SwiftUI
import WidgetKit

struct LiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            LiveActivityView(contenxt: context)
        } dynamicIsland: { context in
            DynamicIsland(expanded: {
                DynamicIslandExpandedRegion(.center) {
                    LiveActivityView(contenxt: context)
                }
            }, compactLeading: {
                LiveActivityView(contenxt: context)
            }, compactTrailing: {
                LiveActivityView(contenxt: context)
            }, minimal: {
                LiveActivityView(contenxt: context)
            })
        }
        
    }
}
