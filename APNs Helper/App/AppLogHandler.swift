//
//  AppLogHandler.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation
import Logging

struct AppLogHandler: LogHandler {

    let appModel: AppModel

    subscript(metadataKey key: String) -> Logging.Logger.Metadata.Value? {
        get {
            return metadata[key]
        }
        set {
            metadata[key] = newValue
        }
    }

    var metadata: Logging.Logger.Metadata = [:]

    var logLevel: Logging.Logger.Level = .trace

    // swiftlint: disable function_parameter_count
    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt) {

            "\(message) \(metadata?.description ?? .empty)".printDebugInfo()

            // 输出到控制台
            let logDate = Date()
            var logContent: String?

            switch level {
            case .error:
                if let metadata = metadata {
                    // 错误信息可能夹带凭据（PEM / device token），统一脱敏
                    logContent = "\(metadata)".maskedForLog
                }
            case .critical, .notice, .info:
                // Payload 日志保持原样（诊断需要逐字节对照），仅隐去 PEM 内容
                logContent = message.description.maskedPEM
            default:
                break
            }

            guard let logContent = logContent else {
                return
            }

            let output = """
        [\(logDate.ISO8601Format(.iso8601))] \(logContent))
        """

            Task { @MainActor in
                // 输出到UI界面
                appModel.appLog.append(output)
            }
        }
    // swiftlint: enable function_parameter_count
}
