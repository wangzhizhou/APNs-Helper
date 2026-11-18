//
//  APNSClientPool.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import Foundation
import APNS
import APNSCore
import NIOPosix

/// 按凭据复用 `APNSClient`。
///
/// 为什么需要复用：
/// - APNs 要求同一把授权 key 的 provider token（JWT）**至少复用 20 分钟**、最长 60 分钟刷新一次。
///   每次发送都新建 client 会不停生成新 JWT，高频发送时可能被 APNs 以
///   `TooManyProviderTokenUpdates` 拒绝（表现为"突然发不出去"）。
/// - 每个 client 都有自己的 EventLoopGroup 和 HTTP/2 连接，复用可省掉重复的 TLS 握手。
///
/// 只在凭据/环境变化时切换 client，并把旧的关掉，避免堆积连接。
@MainActor
final class APNSClientPool {

    static let shared = APNSClientPool()

    private struct ClientKey: Hashable {
        let keyIdentifier: String
        let teamIdentifier: String
        let environment: String
        let privateKeyHash: Int
    }

    private var current: (key: ClientKey, client: APNSClient<JSONDecoder, RawBodyEncoder>)?

    private init() {}

    func client(for config: Config) throws -> APNSClient<JSONDecoder, RawBodyEncoder> {
        let key = ClientKey(
            keyIdentifier: config.keyIdentifier,
            teamIdentifier: config.teamIdentifier,
            environment: config.apnsServerEnv.rawValue,
            privateKeyHash: config.privateKey.hashValue
        )

        if let current, current.key == key {
            return current.client
        }

        // 切换凭据：关掉上一个 client（其 JWT 不再有效/不再需要）
        if let previous = current {
            Task { try? await previous.client.shutdown() }
        }

        let client = APNSClient(
            configuration: .init(
                authenticationMethod: .jwt(
                    privateKey: try .init(pemRepresentation: config.privateKey),
                    keyIdentifier: config.keyIdentifier,
                    teamIdentifier: config.teamIdentifier
                ),
                environment: config.apnsServerEnv.env
            ),
            // APNSwift 新版弃用了 .createNew：统一用一个共享的 EventLoopGroup，
            // 避免每次切换凭据都新建一组线程
            eventLoopGroupProvider: .shared(MultiThreadedEventLoopGroup.singleton),
            responseDecoder: JSONDecoder(),
            requestEncoder: RawBodyEncoder()
        )
        current = (key, client)
        return client
    }

    /// 连接或 JWT 可能已失效（网络切换、长时间空闲、服务端拒绝）时丢弃当前 client。
    func invalidate() {
        shutdown()
    }

    func shutdown() {
        guard let current else { return }
        self.current = nil
        Task { try? await current.client.shutdown() }
    }
}
