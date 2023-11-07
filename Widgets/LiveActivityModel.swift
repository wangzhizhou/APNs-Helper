//
//  LiveActivityModel.swift
//  APNs Helper
//
//  Created by joker on 11/7/23.
//

#if canImport(ActivityKit)
import ActivityKit

struct LiveActivityContentState: Codable, Hashable {
    
    enum LiveActivityStage: String, Codable {
        case none
        case new
        case update
        case end
    }
    
    let stage: LiveActivityStage
}

struct LiveActivityAttributes: ActivityAttributes {
    typealias ContentState = LiveActivityContentState
}
#endif
