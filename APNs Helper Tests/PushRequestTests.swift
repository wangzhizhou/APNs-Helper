import Foundation
import Testing
import APNSCore
import NIOCore
import APNS

@Suite("PushRequest")
struct PushRequestTests {

    private func config(_ pushType: PushType) -> Config {
        Config(
            deviceToken: "alert-token",
            pushKitVoIPToken: "voip-token",
            pushKitFileProviderToken: "fileprovider-token",
            locationPushServiceToken: "location-token",
            liveActivityPushToken: "liveactivity-token",
            appBundleID: "com.example.app",
            privateKey: "key",
            keyIdentifier: "KEYID",
            teamIdentifier: "TEAMID",
            pushType: pushType,
            apnsServerEnv: .production
        )
    }

    @Test("Alert 推送的头信息")
    func alertHeaders() throws {
        let request = PushRequest.make(config: config(.alert), payload: .object([:]))
        let headers = request.headers
        #expect(headers["apns-push-type"] == "alert")
        #expect(headers["apns-topic"] == "com.example.app")
        #expect(headers["apns-priority"] == "10")
        #expect(headers["apns-expiration"] == "0")
        #expect(headers["apns-collapse-id"] == nil)
        #expect(headers["apns-id"] == nil)
    }

    @Test("VoIP / FileProvider / Location / LiveActivity 的 topic 与优先级", arguments: [
        (PushType.voip, "com.example.app.voip", "10", "0"),
        (PushType.fileprovider, "com.example.app.pushkit.fileprovider", "5", "0"),
        (PushType.location, "com.example.app.location-query", "10", nil),
        (PushType.liveactivity, "com.example.app.push-type.liveactivity", "10", "0"),
        (PushType.background, "com.example.app", "5", "0")
    ])
    func specialPushTypes(_ pushType: PushType, _ topic: String, _ priority: String, _ expiration: String?) {
        let headers = PushRequest.make(config: config(pushType), payload: .object([:])).headers
        #expect(headers["apns-topic"] == topic)
        #expect(headers["apns-priority"] == priority)
        #expect(headers["apns-expiration"] == expiration)
        #expect(headers["apns-push-type"] == pushType.rawValue)
    }

    @Test("deviceToken 按推送类型选取")
    func deviceToken() {
        let tokens: [PushType: String] = [
            .alert: "alert-token",
            .background: "alert-token",
            .voip: "voip-token",
            .fileprovider: "fileprovider-token",
            .location: "location-token",
            .liveactivity: "liveactivity-token"
        ]
        for (pushType, token) in tokens {
            #expect(PushRequest.make(config: config(pushType), payload: .object([:])).deviceToken == token)
        }
    }

    @Test("请求体就是用户原始 JSON")
    func bodyIsRawPayload() throws {
        let raw = #"{"aps":{"alert":"hi","badge":1},"custom":true}"#
        let payload = try #require(JSONValue(jsonString: raw))
        let request = PushRequest.make(config: config(.alert), payload: payload)
        #expect(request.message.payload == payload)
        let encoded = try JSONEncoder().encode(request.message)
        let object = try #require(try JSONSerialization.jsonObject(with: encoded) as? NSDictionary)
        #expect((object["aps"] as? NSDictionary)?["alert"] as? String == "hi")
        #expect(object["custom"] as? Bool == true)
    }
}


@Suite("Raw payload 透传")
struct RawPayloadTests {

    private func config() -> Config {
        Config(
            deviceToken: "token",
            pushKitVoIPToken: "voip",
            pushKitFileProviderToken: "fp",
            locationPushServiceToken: "loc",
            liveActivityPushToken: "live",
            appBundleID: "com.example.app",
            privateKey: "key",
            keyIdentifier: "KEYID",
            teamIdentifier: "TEAMID"
        )
    }

    /// 编辑器里的 JSON 必须逐字节成为 HTTP Body：键序、空白、`2.0` 都不能变。
    @Test("请求体与输入逐字节一致")
    func bodyIsByteIdentical() throws {
        let raw = """
        {
          "z": 1,
          "a": 2.0,
          "nested": { "b": 1, "a": 2 },
          "big": 9223372036854775807,
          "unicode": "中文 🚀",
          "nil": null
        }
        """
        let data = Data(raw.utf8)
        let message = try RawPayloadNotification(payloadData: data)

        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        try RawBodyEncoder().encode(message, into: &buffer)

        #expect(buffer.readBytes(length: buffer.readableBytes) == [UInt8](data))
    }

    @Test("非法 JSON 被拦下")
    func rejectsInvalidJSON() {
        #expect(throws: APNsPayloadError.self) {
            _ = try RawPayloadNotification(payloadData: Data("{not json".utf8))
        }
    }

    @Test("非法 JSON 不会构造出请求")
    func requestRejectsInvalidJSON() {
        #expect(throws: APNsPayloadError.self) {
            _ = try PushRequest.make(config: config(), payloadData: Data("nope".utf8))
        }
    }
}
