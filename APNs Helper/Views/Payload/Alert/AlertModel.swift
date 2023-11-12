//
//  AlertModel.swift
//  APNs Helper
//
//  Created by joker on 10/28/23.
//

import Foundation
import APNSCore

typealias RawPayload = [String: String]

typealias AlertNotification = APNSAlertNotification<RawPayload>

@Observable
final class AlertModel {
    
    var alertTitle: String
    
    var alertSubtitle: String
    
    var alertBody: String
    
    var alertLaunchImage: String
    
    var badge: String
    
    var sound: String
    
    var threadID: String
    
    var category: String
    
    var mutableContent: String
    
    var targetContentID: String
    
    var interruptionLevel: String
    
    var relevanceScore: String
    
    var payload: RawPayload
    
    init(
        alertTitle: String = "",
        alertSubtitle: String = "",
        alertBody: String = "",
        alertLaunchImage: String = "",
        badge: String = "",
        sound: String = "",
        threadID: String = "",
        category: String = "",
        mutableContent: String = "",
        targetContentID: String = "",
        interruptionLevel: String = "",
        relevanceScore: String = "",
        payload: RawPayload = RawPayload()) {
            self.alertTitle = alertTitle
            self.alertSubtitle = alertSubtitle
            self.alertBody = alertBody
            self.alertLaunchImage = alertLaunchImage
            self.badge = badge
            self.sound = sound
            self.threadID = threadID
            self.category = category
            self.mutableContent = mutableContent
            self.targetContentID = targetContentID
            self.interruptionLevel = interruptionLevel
            self.relevanceScore = relevanceScore
            self.payload = payload
        }
}

extension AlertModel {
    
    var payloadEditorContent: String? { notification.jsonString }
    
    var notification: AlertNotification {
        AlertNotification(
            alert: .init(
                title: .raw(alertTitle),
                subtitle: .raw(alertSubtitle),
                body: .raw(alertBody),
                launchImage: alertLaunchImage
            ),
            expiration: .immediately,
            priority: .immediately,
            topic: "",
            payload: payload,
            badge: badge.intValue,
            threadID: threadID,
            category: category,
            mutableContent: mutableContent.doubleValue,
            targetContentID: targetContentID,
            relevanceScore: relevanceScore.doubleValue
        )
    }
}
