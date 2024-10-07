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
    
    var randomBackgroundColor: Color { Color.random }
    
    var body: some WidgetConfiguration {
        return ActivityConfiguration(for: LiveActivityAttributes.self) { _ in
            HStack {
                Image(systemName: "clock")
                Text(Date().formatted(.dateTime.year().month().day().hour().minute().second()))
                    .bold()
            }
            .activityBackgroundTint(randomBackgroundColor)
        } dynamicIsland: { _ in
            DynamicIsland(expanded: {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "calendar.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: "gauge.with.needle")
                        .resizable()
                        .frame(width: 60, height: 60)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(Date().formatted(.dateTime.year().month().day()))
                        .font(.title)
                        .bold()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(Date().formatted(.dateTime.hour().minute().second()))
                        .font(.title3)
                        .bold()
                }
            }, compactLeading: {
                Text(Date().formatted(.dateTime.month().day()))
            }, compactTrailing: {
                Text(Date().formatted(.dateTime.hour().minute()))
            }, minimal: {
                Image(systemName: "app.badge.fill")
                    .symbolEffect(.pulse)
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
