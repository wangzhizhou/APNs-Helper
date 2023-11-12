//
//  LiveActivityModel.swift
//  APNs Helper
//
//  Created by joker on 10/29/23.
//

import Foundation
import APNSCore

@Observable
final class LiveActivityModel {
    
    enum Event: String, CaseIterable, Identifiable {
        case update
        case end
        
        var id: String { self.rawValue }
    }
    
    var timestamp: String
    
    var event: Event
    
    var contentState: String
    
    var dismissal: String
    
    
    init(
        timestamp: String = "",
        event: Event = .update,
        contentState: String = "{}",
        dismissal: String = ""
    ) {
        self.timestamp = timestamp
        self.event = event
        self.contentState = contentState
        self.dismissal = dismissal
    }
}

extension LiveActivityModel {
    
    var payloadEditorContent: String? { notification.jsonString }
    
    typealias RawContentState = [String: String]
    
    var notification: APNSLiveActivityNotification<RawContentState> {
        
        var rawContentState = RawContentState()
        
        if let data = contentState.trimmed.data(using: .utf8), let contentState =  try? JSONDecoder().decode(RawContentState.self, from: data) {
            rawContentState = contentState
        }
        
        var dismissalDate: APNSLiveActivityDismissalDate = .none
        
        if let dismissal = dismissal.intValue {
            dismissalDate = .timeIntervalSince1970InSeconds(dismissal)
        }
        
        return APNSLiveActivityNotification(
            expiration: .immediately,
            priority: .immediately,
            topic: "",
            contentState: rawContentState,
            event: liveActivityNotificationEvent,
            timestamp: timestamp.intValue ?? Int(Date(timeIntervalSinceNow: 2).timeIntervalSince1970),
            dismissalDate: dismissalDate
        )
    }
    
    var liveActivityNotificationEvent: APNSLiveActivityNotificationEvent {
        switch event {
        case .update:
            return .update
        case .end:
            return .end
        }
    }
}
