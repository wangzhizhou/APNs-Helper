//
//  DevSecretsTests.swift
//  APNs Helper Tests
//
//  自测凭据的校验与序列化（不触碰 Keychain）。
//

import Foundation
import Testing

@Suite("自测凭据")
struct DevSecretsTests {

    private let validKey = """
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgViPOgSdnJxJ2gXfH
    R9xPBxTb6z1Jv0aT0j9Z9cQ0mS7Jr1o2yW3k4l5n6o7p8q9r0s1t2u3v4w5x6y7z
    -----END PRIVATE KEY-----
    """

    @Test("完整凭据通过校验")
    func acceptsValidCredentials() {
        let error = DevSecrets.validationError(
            keyIdentifier: "7S6SUT5L43",
            teamIdentifier: "2N62934Y28",
            privateKey: validKey
        )
        #expect(error == nil)
    }

    @Test("Key ID / Team ID 长度不对时报错")
    func rejectsWrongIdentifierLength() {
        #expect(DevSecrets.validationError(
            keyIdentifier: "7S6SUT5L4", teamIdentifier: "2N62934Y28", privateKey: validKey
        ) == "Key ID should be 10 characters.")

        #expect(DevSecrets.validationError(
            keyIdentifier: "7S6SUT5L43", teamIdentifier: "2N6293", privateKey: validKey
        ) == "Team ID should be 10 characters.")
    }

    @Test("缺少私钥时报错")
    func rejectsEmptyKey() {
        #expect(DevSecrets.validationError(
            keyIdentifier: "7S6SUT5L43", teamIdentifier: "2N62934Y28", privateKey: "   "
        ) == ".p8 private key is required.")
    }

    @Test("不是 PEM 私钥时报错")
    func rejectsNonPEM() {
        let error = DevSecrets.validationError(
            keyIdentifier: "7S6SUT5L43",
            teamIdentifier: "2N62934Y28",
            privateKey: "not a key"
        )
        #expect(error == ".p8 must be a PKCS#8 PEM block (BEGIN/END PRIVATE KEY).")
    }

    @Test("只有首尾标记、正文过短时报截断")
    func rejectsTruncatedKey() {
        let error = DevSecrets.validationError(
            keyIdentifier: "7S6SUT5L43",
            teamIdentifier: "2N62934Y28",
            privateKey: "-----BEGIN PRIVATE KEY-----\nMIIB\n-----END PRIVATE KEY-----"
        )
        #expect(error == ".p8 content looks truncated.")
    }

    @Test("CRLF 与首尾空白会被规范化")
    func normalizesLineEndings() {
        let crlf = "  -----BEGIN PRIVATE KEY-----\r\nMIIB\r\n-----END PRIVATE KEY-----\n  "
        let normalized = DevSecrets.normalize(crlf)
        #expect(!normalized.contains("\r"))
        #expect(normalized.hasPrefix("-----BEGIN PRIVATE KEY-----"))
        #expect(normalized.hasSuffix("-----END PRIVATE KEY-----"))
    }

    @Test("Payload 编解码往返一致")
    func payloadRoundTrip() throws {
        let payload = DevSecrets.Payload(
            keyIdentifier: "7S6SUT5L43",
            teamIdentifier: "2N62934Y28",
            privateKey: validKey
        )
        let data = try #require(DevSecrets.encode(payload))
        #expect(DevSecrets.decode(data) == payload)
        #expect(DevSecrets.decode(Data("{}".utf8)) == nil)
    }
}
