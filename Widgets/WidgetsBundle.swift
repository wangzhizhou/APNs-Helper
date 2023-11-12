//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by joker on 2023/10/30.
//
#if canImport(WidgetKit)
import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        Widgets()
#if os(iOS)
        LiveActivity()
#endif
    }
}
#endif
