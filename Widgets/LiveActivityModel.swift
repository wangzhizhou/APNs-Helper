//
//  LiveActivityModel.swift
//  APNs Helper
//
//  Created by joker on 11/7/23.
//

import ActivityKit

struct LiveActivityContentState: Codable, Hashable {
    
}

struct LiveActivityAttributes: ActivityAttributes {
    typealias ContentState = LiveActivityContentState
}
