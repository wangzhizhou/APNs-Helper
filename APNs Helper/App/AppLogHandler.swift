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
                
        // 输出到控制台
        
        let output = message.description
        print(output)
        Task {
            await MainActor.run {
                // 输出到UI界面
                APNsHelperApp.model.appLog.append(output)
            }
        }
    }
}
