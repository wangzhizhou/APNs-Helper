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
        let randomColor = Color.random
        return ActivityConfiguration(for: LiveActivityAttributes.self) { _ in
            HStack {
                Image(systemName: "clock")
                Text(Date().formatted(.dateTime.year().month().day().hour().minute().second()))
                    .bold()
            }
            .activityBackgroundTint(randomColor)
        } dynamicIsland: { _ in
            DynamicIsland(expanded: {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "calendar.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .offset(y: 30)
                        .activityBackgroundTint(randomColor)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: "gauge.with.needle")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .offset(y: 30)
                        .activityBackgroundTint(randomColor)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(Date().formatted(.dateTime.year().month().day()))
                        .font(.title)
                        .bold()
                        .activityBackgroundTint(randomColor)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(Date().formatted(.dateTime.hour().minute().second()))
                        .font(.title3)
                        .bold()
                        .activityBackgroundTint(randomColor)
                }
            }, compactLeading: {
                Text(Date().formatted(.dateTime.month().day()))
                    .activityBackgroundTint(randomColor)
            }, compactTrailing: {
                Text(Date().formatted(.dateTime.hour().minute()))
                    .activityBackgroundTint(randomColor)
            }, minimal: {
                Image(systemName: "app.badge.fill")
                    .symbolEffect(.pulse.wholeSymbol)
                    .activityBackgroundTint(randomColor)
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
