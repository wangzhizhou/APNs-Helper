//
//  AppLogHandler.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation
import Logging

struct AppLogHandler: LogHandler {
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
    
    func log(level: Logger.Level,
             message: Logger.Message,
             metadata: Logger.Metadata?,
             source: String,
             file: String,
             function: String,
             line: UInt) {
        
        Task {
            await MainActor.run {
                APNsHelperApp.model.appLog.append(message.description)
                APNsHelperApp.model.appLog.append("\n")
            }
        }
    }
}
