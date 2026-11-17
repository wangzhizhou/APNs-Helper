//
//  PushTypeTests.swift
//  APNs Helper Tests
//
//  Created by joker on 2025/11/17.
//

import Foundation
import Testing

@Suite("PushType")
struct PushTypeTests {

    @Test("Topic 与 APNs 规范一致", arguments: [
        (PushType.alert, "com.example.app"),
        (PushType.background, "com.example.app"),
        (PushType.voip, "com.example.app.voip"),
        (PushType.fileprovider, "com.example.app.pushkit.fileprovider"),
        (PushType.location, "com.example.app.location-query"),
        (PushType.liveactivity, "com.example.app.push-type.liveactivity")
    ])
    func topic(_ pushType: PushType, _ expected: String) {
        #expect(pushType.topic(forBundleID: "com.example.app") == expected)
    }

    @Test("Topic 后缀与类型一一对应")
    func topicSuffix() {
        #expect(PushType.alert.topicSuffix == nil)
        #expect(PushType.background.topicSuffix == nil)
        #expect(PushType.voip.topicSuffix == ".voip")
        #expect(PushType.fileprovider.topicSuffix == ".pushkit.fileprovider")
        #expect(PushType.location.topicSuffix == ".location-query")
        #expect(PushType.liveactivity.topicSuffix == ".push-type.liveactivity")
    }

    @Test("background / fileprovider 必须使用优先级 5")
    func lowPriorityPushTypes() {
        #expect(PushType.background.priorityValue == 5)
        #expect(PushType.fileprovider.priorityValue == 5)
        #expect(PushType.alert.priorityValue == 10)
        #expect(PushType.voip.priorityValue == 10)
        #expect(PushType.liveactivity.priorityValue == 10)
    }

    @Test("Location 推送不使用 apns-expiration")
    func locationExpiration() {
        #expect(!PushType.location.usesImmediateExpiration)
        for pushType in PushType.allCases where pushType != .location {
            #expect(pushType.usesImmediateExpiration)
        }
    }

    @Test("每种推送类型取到对应的 Token")
    func deviceTokenSelection() {
        let config = Config(
            deviceToken: "alert",
            pushKitVoIPToken: "voip",
            pushKitFileProviderToken: "fileprovider",
            locationPushServiceToken: "location",
            liveActivityPushToken: "liveactivity",
            appBundleID: "com.example.app",
            privateKey: "key",
            keyIdentifier: "keyID",
            teamIdentifier: "teamID"
        )
        #expect(PushType.alert.deviceToken(in: config) == "alert")
        #expect(PushType.background.deviceToken(in: config) == "alert")
        #expect(PushType.voip.deviceToken(in: config) == "voip")
        #expect(PushType.fileprovider.deviceToken(in: config) == "fileprovider")
        #expect(PushType.location.deviceToken(in: config) == "location")
        #expect(PushType.liveactivity.deviceToken(in: config) == "liveactivity")
    }

    @Test("PushType 可编码解码")
    func codable() throws {
        for pushType in PushType.allCases {
            let data = try JSONEncoder().encode(pushType)
            #expect(try JSONDecoder().decode(PushType.self, from: data) == pushType)
        }
    }
}
