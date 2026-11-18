import Foundation
import Testing
import APNSCore
import NIOCore
import APNS

@Suite("PushRequest")
struct PushRequestTests {

    private func config(_ pushType: PushType) -> Config {
        Config(
            deviceToken: String(repeating: "a1", count: 32),
            pushKitVoIPToken: String(repeating: "b2", count: 32),
            pushKitFileProviderToken: String(repeating: "c3", count: 32),
            locationPushServiceToken: String(repeating: "d4", count: 32),
            liveActivityPushToken: String(repeating: "e5", count: 32),
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
        let request = try PushRequest.make(config: config(.alert), payload: .object([:]))
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
    func specialPushTypes(_ pushType: PushType, _ topic: String, _ priority: String, _ expiration: String?) throws {
        let headers = try PushRequest.make(config: config(pushType), payload: .object([:])).headers
        #expect(headers["apns-topic"] == topic)
        #expect(headers["apns-priority"] == priority)
        #expect(headers["apns-expiration"] == expiration)
        #expect(headers["apns-push-type"] == pushType.rawValue)
    }

    @Test("deviceToken 按推送类型选取")
    func deviceToken() throws {
        let alertToken = String(repeating: "a1", count: 32)
        let tokens: [PushType: String] = [
            .alert: alertToken,
            .background: alertToken,
            .voip: String(repeating: "b2", count: 32),
            .fileprovider: String(repeating: "c3", count: 32),
            .location: String(repeating: "d4", count: 32),
            .liveactivity: String(repeating: "e5", count: 32)
        ]
        for (pushType, token) in tokens {
            #expect((try PushRequest.make(config: config(pushType), payload: .object([:]))).deviceToken == token)
        }
    }

    @Test("请求体就是用户原始 JSON")
    func bodyIsRawPayload() throws {
        let raw = #"{"aps":{"alert":"hi","badge":1},"custom":true}"#
        let payload = try #require(JSONValue(jsonString: raw))
        let request = try PushRequest.make(config: config(.alert), payload: payload)
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

@Suite("请求头输入校验")
struct PushRequestValidationTests {

    private func config(bundleID: String = "com.example.app", token: String = String(repeating: "ab", count: 32)) -> Config {
        Config(
            deviceToken: token,
            pushKitVoIPToken: token,
            pushKitFileProviderToken: token,
            locationPushServiceToken: token,
            liveActivityPushToken: token,
            appBundleID: bundleID,
            privateKey: "key",
            keyIdentifier: "KEYID",
            teamIdentifier: "TEAMID"
        )
    }

    @Test("正常 bundle id 与十六进制 token 通过")
    func acceptsValidValues() throws {
        let request = try PushRequest.make(config: config(), payloadData: Data("{}".utf8))
        #expect(request.headers["apns-topic"] == "com.example.app")
    }

    /// 参考 GHSA-q3g2-m552-3r9c：header 值里不能出现 CR/LF
    @Test("bundle id 中的换行/回车被拒绝", arguments: ["com.example\r\nInjected: 1", "com.example\napp", "com.example app"])
    func rejectsUnsafeBundleID(_ bundleID: String) {
        #expect(throws: PushRequestError.self) {
            _ = try PushRequest.make(config: config(bundleID: bundleID), payloadData: Data("{}".utf8))
        }
    }

    @Test("非十六进制的 device token 被拒绝", arguments: ["token-with-dash", "abc def", "abc\r\ndef"])
    func rejectsUnsafeDeviceToken(_ token: String) {
        #expect(throws: PushRequestError.self) {
            _ = try PushRequest.make(config: config(token: token), payloadData: Data("{}".utf8))
        }
    }
}
