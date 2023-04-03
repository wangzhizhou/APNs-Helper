//
//  APNsService+MacOS.swift
//  APNs Helper
//
//  Created by joker on 2023/4/3.
//

import Foundation

extension APNsService {
    func sendToSimulator(with data: Data) throws {
#if os(macOS)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "simctl",
            "push",
            "booted",
            "\(config.appBundleID)",
            "-"
        ]
        let inputPipe = Pipe()
        let outputAndErrorPipe = Pipe()
        process.standardInput = inputPipe
        process.standardError = outputAndErrorPipe
        process.standardOutput = outputAndErrorPipe
        let inputHandler = inputPipe.fileHandleForWriting
        inputHandler.write(data)
        inputHandler.closeFile()
        try process.run()
        if let log = String(data: outputAndErrorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) {
            Self.logger.trace(.init(stringLiteral: log))
        }
#endif
    }
}
