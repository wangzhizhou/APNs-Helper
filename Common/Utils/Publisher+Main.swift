//
//  Publisher+Main.swift
//  APNs Helper
//
//  Created by joker on 2025/11/17.
//

import Foundation
import Combine

extension Publisher where Failure == Never {

    /// 在主线程序列上订阅。
    ///
    /// `@MainActor` 的模型会从 PushKit / CoreLocation / UserNotifications 等
    /// 非主线程回调里被更新，统一在这里切回主线程，避免每个订阅点都写 `receive(on:)`。
    func sinkOnMain(_ receiveValue: @escaping (Output) -> Void) -> AnyCancellable {
        receive(on: DispatchQueue.main).sink(receiveValue: receiveValue)
    }
}
